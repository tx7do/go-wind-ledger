package service

import (
	"context"
	"slices"

	"github.com/go-kratos/kratos/v2/log"

	adminV1 "go-wind-ledger/api/gen/go/admin/service/v1"

	"go-wind-ledger/pkg/constants"

	"go-wind-ledger/pkg/middleware/auth"
)

// requirePlatformAdmin 把平台专用服务的变更入口挡在平台管理员之内。
//
// 移植自上游 go-wind-admin da2b3a5f（原为通知域守卫，上游扩展为平台专用服务
// 变更入口的统一闸门）：租户/菜单/权限/接口/语言/登录策略等是平台全局资源，
// 模块白名单闸门可能因租户自助能力把它们常态放行，一道护栏不该靠漏配存在。
//
// 判定优先取 token 的 IsPlatformAdmin 旗标；本仓登录链路尚未填充该旗标
// （上游由 fillAdminFlags 按角色码填充，本仓未移植），故按角色码回退判定——
// 角色码经 JWT "roc" claim 全程往返，语义与旗标同源（platform:admin）。
func requirePlatformAdmin(ctx context.Context, log *log.Helper, resource string) error {
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return err
	}

	if operator.GetIsPlatformAdmin() || slices.Contains(operator.GetRoles(), constants.PlatformAdminRoleCode) {
		return nil
	}

	log.Errorf("operator [%d] (tenant %d) is not a platform administrator, %s access denied",
		operator.GetUserId(), operator.GetTenantId(), resource)

	return adminV1.ErrorForbidden("%s is platform-level configuration, only platform administrators may access it", resource)
}
