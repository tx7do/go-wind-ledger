package service

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/go-utils/trans"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-crud/viewer"

	"go-wind-ledger/app/core/service/internal/data"
	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/book"
	"go-wind-ledger/app/core/service/internal/data/ent/membership"
	"go-wind-ledger/app/core/service/internal/data/ent/privacy"
	"go-wind-ledger/app/core/service/internal/data/ent/tenant"
	"go-wind-ledger/app/core/service/internal/data/ent/user"
	"go-wind-ledger/app/core/service/internal/data/ent/usercredential"

	appV1 "go-wind-ledger/api/gen/go/app/service/v1"
	authenticationV1 "go-wind-ledger/api/gen/go/authentication/service/v1"
	identityV1 "go-wind-ledger/api/gen/go/identity/service/v1"
	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"

	"go-wind-ledger/pkg/metadata"
	"go-wind-ledger/pkg/middleware/auth"
)

// defaultInviteCode 默认邀请码（未配置时使用）
const defaultInviteCode = "111111"

// defaultCurrencyCode 默认币种代码
const defaultCurrencyCode = "CNY"

// userCredentialIdentityType 用户凭证身份类型（与现有 VerifyCredential 查询保持一致：空串）
const userCredentialIdentityType = ""

// userCredentialCredentialType 用户凭证凭据类型（PASSWORD_HASH，与现有 verifyCredential 分支一致）
const userCredentialCredentialType = "PASSWORD_HASH"

// LedgerAuthService 记账认证服务（Core 实现）— 扩展注册/初始化/切换
type LedgerAuthService struct {
	appV1.UnimplementedLedgerAuthServiceServer

	entClient *entCrud.EntClient[*ent.Client]

	userRepo       data.UserRepo
	tenantRepo     *data.TenantRepo
	bookRepo       *data.BookRepo
	membershipRepo *data.MembershipRepo

	authenticator *data.Authenticator

	log *log.Helper
}

// NewLedgerAuthService 创建记账认证服务
func NewLedgerAuthService(
	ctx *bootstrap.Context,
	entClient *entCrud.EntClient[*ent.Client],
	authenticator *data.Authenticator,
	userRepo data.UserRepo,
	tenantRepo *data.TenantRepo,
	bookRepo *data.BookRepo,
	membershipRepo *data.MembershipRepo,
) *LedgerAuthService {
	return &LedgerAuthService{
		log:            log.NewHelper(log.With(ctx.GetLogger(), "module", "ledger-auth/service/core-service")),
		entClient:      entClient,
		authenticator:  authenticator,
		userRepo:       userRepo,
		tenantRepo:     tenantRepo,
		bookRepo:       bookRepo,
		membershipRepo: membershipRepo,
	}
}

// newPrivacyCtx 创建绕过隐私保护/带 viewer 的上下文（用于注册等无认证上下文的场景）
func newPrivacyCtx(ctx context.Context) context.Context {
	ctx = viewer.WithContext(ctx, viewer.NewNoopContext())
	ctx = privacy.DecisionContext(ctx, privacy.Allow)
	ctx, _ = metadata.NewContext(ctx, metadata.NewUserOperator(0, 0, 0, identityV1.DataScope_ALL))
	return ctx
}

// Register 用户注册（自动创建默认租户和账本）
func (s *LedgerAuthService) Register(ctx context.Context, req *appV1.LedgerRegisterRequest) (*appV1.LedgerAuthResponse, error) {
	if req == nil {
		return nil, identityV1.ErrorBadRequest("invalid request")
	}

	// 1. 验证邀请码（为空时使用默认邀请码）
	inviteCode := req.GetInviteCode()
	if inviteCode == "" {
		inviteCode = defaultInviteCode
	}
	if inviteCode != defaultInviteCode {
		return nil, identityV1.ErrorBadRequest("invalid invite code")
	}

	username := req.GetUsername()
	if username == "" {
		return nil, identityV1.ErrorBadRequest("username is required")
	}
	if req.GetPassword() == "" {
		return nil, identityV1.ErrorBadRequest("password is required")
	}

	// 注册流程无认证上下文，使用隐私绕过上下文
	privacyCtx := newPrivacyCtx(ctx)

	// 2. 检查用户名是否已存在
	existResp, err := s.userRepo.UserExists(privacyCtx, &identityV1.UserExistsRequest{
		QueryBy: &identityV1.UserExistsRequest_Username{Username: username},
	})
	if err != nil {
		s.log.Errorf("check user exists failed: %v", err)
		return nil, err
	}
	if existResp.GetExist() {
		return nil, identityV1.ErrorBadRequest("username already exists")
	}

	// 开启事务，保证用户/凭证/租户/账本/成员关系原子性
	tx, err := s.entClient.Client().Tx(privacyCtx)
	if err != nil {
		s.log.Errorf("start transaction failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("start transaction failed")
	}
	committed := false
	defer func() {
		if !committed {
			if rollbackErr := tx.Rollback(); rollbackErr != nil {
				s.log.Errorf("transaction rollback failed: %s", rollbackErr.Error())
			}
		}
	}()

	// 3. 创建默认租户（先于用户创建，以便绑定 user.tenant_id 外键）
	tenantEntity, err := tx.Tenant.Create().
		SetNillableName(trans.Ptr("我的账本")).
		SetDefaultCurrencyCode(defaultCurrencyCode).
		SetCreatedAt(time.Now()).
		Save(privacyCtx)
	if err != nil {
		s.log.Errorf("create tenant failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("create tenant failed")
	}

	// 4. 创建用户（绑定 tenant_id 外键）
	nickName := req.GetNickName()
	if nickName == "" {
		nickName = username
	}
	userEntity, err := tx.User.Create().
		SetTenantID(tenantEntity.ID).
		SetNillableUsername(trans.Ptr(username)).
		SetNillableNickname(trans.Ptr(nickName)).
		SetStatus(user.StatusUserStatusNormal).
		SetCreatedAt(time.Now()).
		Save(privacyCtx)
	if err != nil {
		s.log.Errorf("create user failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("create user failed")
	}

	// 5. 创建用户凭证（密码）
	// 注意：ent schema 中 identity_type/credential_type 为 plain string，status 为 string 枚举。
	// 与现有 VerifyCredential 查询保持一致：identity_type 存空串、credential_type 存 "PASSWORD_HASH"。
	// 密码以明文写入（与现有 prepareCredential default 分支一致）；完整 bcrypt 哈希由
	// userCredentialRepo.CreateWithTx 处理（该路径在 PrepareCredential 中对 PASSWORD_HASH 加密）。
	// 这里为保持事务一致性直接写入明文，登录时 VerifyCredential 默认不走 PASSWORD_HASH 哈希校验分支
	// 仅当 NeedDecrypt=true 时走明文比对，故需保持与现有 RegisterUser 一致的明文存储。
	if err = tx.UserCredential.Create().
		SetUserID(userEntity.ID).
		SetTenantID(tenantEntity.ID).
		SetIdentifier(username).
		SetIdentityType(userCredentialIdentityType).
		SetCredentialType(userCredentialCredentialType).
		SetCredential(req.GetPassword()).
		SetStatus(usercredential.StatusStatusActive).
		SetIsPrimary(true).
		SetCreatedAt(time.Now()).
		Exec(privacyCtx); err != nil {
		s.log.Errorf("create user credential failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("create user credential failed")
	}

	// 6. 回填租户管理员用户ID
	if _, err = tx.Tenant.UpdateOneID(tenantEntity.ID).
		SetAdminUserID(userEntity.ID).
		Save(privacyCtx); err != nil {
		s.log.Errorf("update tenant admin failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("update tenant admin failed")
	}

	// 7. 创建所有者成员关系
	if _, err = tx.Membership.Create().
		SetTenantID(tenantEntity.ID).
		SetUserID(userEntity.ID).
		SetStatus(membership.StatusActive).
		SetIsPrimary(true).
		SetCreatedAt(time.Now()).
		SetJoinedAt(time.Now()).
		Save(privacyCtx); err != nil {
		s.log.Errorf("create membership failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("create membership failed")
	}

	// 8. 创建默认账本
	bookEntity, err := tx.Book.Create().
		SetTenantID(tenantEntity.ID).
		SetNillableName(trans.Ptr("默认账本")).
		SetDefaultCurrencyCode(defaultCurrencyCode).
		SetEnable(true).
		SetCreatedAt(time.Now()).
		Save(privacyCtx)
	if err != nil {
		s.log.Errorf("create book failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("create book failed")
	}

	// 9. 设置用户默认租户和账本
	if _, err = tx.User.UpdateOneID(userEntity.ID).
		SetDefaultGroupID(tenantEntity.ID).
		SetDefaultBookID(bookEntity.ID).
		SetUpdatedAt(time.Now()).
		Save(privacyCtx); err != nil {
		s.log.Errorf("update user default group/book failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("update user default failed")
	}

	// 10. 设置租户默认账本
	if _, err = tx.Tenant.UpdateOneID(tenantEntity.ID).
		SetDefaultBookID(bookEntity.ID).
		SetUpdatedAt(time.Now()).
		Save(privacyCtx); err != nil {
		s.log.Errorf("update tenant default book failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("update tenant default book failed")
	}

	if err = tx.Commit(); err != nil {
		s.log.Errorf("transaction commit failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("transaction commit failed")
	}
	committed = true

	// 10. 生成 JWT token 并返回
	accessToken, refreshToken, tokenErr := s.authenticator.CreateUserToken(ctx, authenticationV1.ClientType_app, &authenticationV1.UserTokenPayload{
		UserId:   userEntity.ID,
		TenantId: trans.Ptr(tenantEntity.ID),
		Username: trans.Ptr(username),
	})
	if tokenErr != nil {
		s.log.Errorf("create user token failed: %s", tokenErr.Error())
		// 注册成功但 token 生成失败时，仍返回用户名（空 token），让用户重新登录
		return &appV1.LedgerAuthResponse{
			Username: trans.Ptr(username),
		}, nil
	}

	return &appV1.LedgerAuthResponse{
		AccessToken:  accessToken,
		RefreshToken: trans.Ptr(refreshToken),
		Username:     trans.Ptr(username),
	}, nil
}

// InitState 初始化状态（返回用户/租户/账本聚合信息）
func (s *LedgerAuthService) InitState(ctx context.Context, _ *emptypb.Empty) (*appV1.InitStateResponse, error) {
	// 1. 从认证上下文获取当前用户 ID
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	userID := operator.GetUserId()
	if userID == 0 {
		return nil, identityV1.ErrorBadRequest("invalid user id")
	}

	privacyCtx := newPrivacyCtx(ctx)

	// 2. 查询用户信息（proto User 不含 default_book_id/default_group_id，需 ent 实体）
	userEntity, err := s.entClient.Client().User.Query().
		Where(user.IDEQ(userID)).
		Only(privacyCtx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, identityV1.ErrorNotFound("user not found")
		}
		s.log.Errorf("get user failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("get user failed")
	}

	// proto User 信息（供前端展示）
	userInfo, err := s.userRepo.Get(privacyCtx, &identityV1.GetUserRequest{
		QueryBy: &identityV1.GetUserRequest_Id{Id: userID},
	})
	if err != nil {
		s.log.Errorf("get user (proto) failed: %s", err.Error())
	}
	resp := &appV1.InitStateResponse{
		User: userInfo,
	}

	// 3. 查询用户可访问的租户（通过 membership 关联）
	memberships, err := s.membershipRepo.FindByUser(privacyCtx, userID)
	if err != nil {
		s.log.Errorf("find memberships by user failed: %s", err.Error())
	}
	var availableTenantIDs []uint32
	for _, m := range memberships {
		if m.GetTenantId() > 0 {
			availableTenantIDs = append(availableTenantIDs, m.GetTenantId())
		}
	}

	// 默认租户：优先使用 user.tenant_id（注册时设置）
	defaultTenantID := operator.GetTenantId()
	if defaultTenantID == 0 && userEntity.TenantID != nil {
		defaultTenantID = *userEntity.TenantID
	}
	if defaultTenantID > 0 {
		if tenantInfo, err := s.tenantRepo.Get(privacyCtx, &identityV1.GetTenantRequest{
			QueryBy: &identityV1.GetTenantRequest_Id{Id: defaultTenantID},
		}); err == nil {
			resp.Tenant = tenantInfo
		}
	}

	// 4. 查询用户的默认账本（user.default_book_id）
	defaultBookID := uint32(0)
	if userEntity.DefaultBookID != nil {
		defaultBookID = *userEntity.DefaultBookID
	}
	if defaultBookID > 0 {
		if bookInfo, err := s.bookRepo.Get(privacyCtx, defaultBookID); err == nil {
			resp.Book = bookInfo
		}
	}

	// 5. 查询用户可用的所有账本（属于用户可访问的租户）
	if len(availableTenantIDs) > 0 {
		bookEntities, qErr := s.entClient.Client().Book.Query().
			Where(book.TenantIDIn(availableTenantIDs...)).
			All(privacyCtx)
		if qErr != nil {
			s.log.Errorf("list available books failed: %s", qErr.Error())
		} else {
			books := make([]*ledgerV1.Book, 0, len(bookEntities))
			for _, b := range bookEntities {
				books = append(books, mapEntBookToProto(b))
			}
			resp.AvailableBooks = books
		}
	}

	// 6. 查询用户可用的所有租户
	if len(availableTenantIDs) > 0 {
		tenantInfos, err := s.tenantRepo.ListTenantsByIds(privacyCtx, availableTenantIDs)
		if err != nil {
			s.log.Errorf("list available tenants failed: %s", err.Error())
		} else {
			resp.AvailableTenants = tenantInfos
		}
	}

	return resp, nil
}

// SetDefaultBook 设置默认账本
func (s *LedgerAuthService) SetDefaultBook(ctx context.Context, req *appV1.SetDefaultBookRequest) (*emptypb.Empty, error) {
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	userID := operator.GetUserId()
	if userID == 0 {
		return nil, identityV1.ErrorBadRequest("invalid user id")
	}
	if req.GetBookId() == 0 {
		return nil, identityV1.ErrorBadRequest("invalid book id")
	}

	privacyCtx := newPrivacyCtx(ctx)

	// 1. 验证 book 属于用户可访问的租户
	bookEntity, err := s.entClient.Client().Book.Query().
		Where(book.IDEQ(req.GetBookId())).
		Only(privacyCtx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("book not found")
		}
		s.log.Errorf("query book failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("query book failed")
	}
	if bookEntity.TenantID == nil {
		return nil, identityV1.ErrorBadRequest("book has no tenant")
	}

	// 检查用户是否属于该租户
	if _, err := s.membershipRepo.FindByTenantAndUser(privacyCtx, *bookEntity.TenantID, userID); err != nil {
		return nil, identityV1.ErrorForbidden("book not accessible")
	}

	// 2. 更新 user.default_book_id
	if _, err := s.entClient.Client().User.UpdateOneID(userID).
		SetDefaultBookID(req.GetBookId()).
		SetUpdatedAt(time.Now()).
		Save(privacyCtx); err != nil {
		s.log.Errorf("update user default book failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("update user default book failed")
	}

	return &emptypb.Empty{}, nil
}

// SetDefaultTenant 设置默认租户
func (s *LedgerAuthService) SetDefaultTenant(ctx context.Context, req *appV1.SetDefaultTenantRequest) (*emptypb.Empty, error) {
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	userID := operator.GetUserId()
	if userID == 0 {
		return nil, identityV1.ErrorBadRequest("invalid user id")
	}
	if req.GetTenantId() == 0 {
		return nil, identityV1.ErrorBadRequest("invalid tenant id")
	}

	privacyCtx := newPrivacyCtx(ctx)

	// 1. 验证用户属于该租户（membership 存在）
	if _, err := s.membershipRepo.FindByTenantAndUser(privacyCtx, req.GetTenantId(), userID); err != nil {
		return nil, identityV1.ErrorForbidden("tenant not accessible")
	}

	// 2. 查询该租户的默认账本
	tenantEntity, err := s.entClient.Client().Tenant.Query().
		Where(tenant.IDEQ(req.GetTenantId())).
		Only(privacyCtx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, identityV1.ErrorNotFound("tenant not found")
		}
		s.log.Errorf("query tenant failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("query tenant failed")
	}

	// 3. 更新 user.default_group_id 和 default_book_id
	// 注：user.tenant_id 不可通过 UpdateOne 修改，仅更新 default_group_id 与 default_book_id 指针
	userUpdateBuilder := s.entClient.Client().User.UpdateOneID(userID).
		SetDefaultGroupID(req.GetTenantId()).
		SetUpdatedAt(time.Now())

	if tenantEntity.DefaultBookID != nil && *tenantEntity.DefaultBookID > 0 {
		userUpdateBuilder = userUpdateBuilder.SetDefaultBookID(*tenantEntity.DefaultBookID)
	}

	if _, err := userUpdateBuilder.Save(privacyCtx); err != nil {
		s.log.Errorf("update user default tenant failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("update user default tenant failed")
	}

	return &emptypb.Empty{}, nil
}

// mapEntBookToProto 将 ent.Book 转换为 ledgerV1.Book
func mapEntBookToProto(b *ent.Book) *ledgerV1.Book {
	if b == nil {
		return nil
	}
	book := &ledgerV1.Book{}
	if b.ID != 0 {
		book.Id = trans.Ptr(b.ID)
	}
	if b.TenantID != nil {
		book.TenantId = b.TenantID
	}
	if b.Name != nil {
		book.Name = b.Name
	}
	if b.DefaultCurrencyCode != nil {
		book.DefaultCurrencyCode = b.DefaultCurrencyCode
	}
	if b.Enable != nil {
		book.Enable = b.Enable
	}
	if b.Notes != nil {
		book.Notes = b.Notes
	}
	if b.ExportAt != nil {
		book.ExportAt = b.ExportAt
	}
	if b.DefaultExpenseAccountID != nil {
		book.DefaultExpenseAccountId = b.DefaultExpenseAccountID
	}
	if b.DefaultIncomeAccountID != nil {
		book.DefaultIncomeAccountId = b.DefaultIncomeAccountID
	}
	if b.DefaultTransferFromAccountID != nil {
		book.DefaultTransferFromAccountId = b.DefaultTransferFromAccountID
	}
	if b.DefaultTransferToAccountID != nil {
		book.DefaultTransferToAccountId = b.DefaultTransferToAccountID
	}
	if b.DefaultExpenseCategoryID != nil {
		book.DefaultExpenseCategoryId = b.DefaultExpenseCategoryID
	}
	if b.DefaultIncomeCategoryID != nil {
		book.DefaultIncomeCategoryId = b.DefaultIncomeCategoryID
	}
	if b.CreatedAt != nil {
		book.CreatedAt = timestamppb.New(*b.CreatedAt)
	}
	if b.UpdatedAt != nil {
		book.UpdatedAt = timestamppb.New(*b.UpdatedAt)
	}
	return book
}
