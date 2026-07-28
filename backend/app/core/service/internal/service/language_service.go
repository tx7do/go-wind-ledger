package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-cms/app/core/service/internal/data"

	dictV1 "go-wind-cms/api/gen/go/dict/service/v1"
)

type LanguageService struct {
	dictV1.UnimplementedLanguageServiceServer
	repo *data.LanguageRepo
	log  *log.Helper
}

func NewLanguageService(ctx *bootstrap.Context, repo *data.LanguageRepo) *LanguageService {
	return &LanguageService{
		log:  ctx.NewLoggerHelper("language/service/core-service"),
		repo: repo,
	}
}

func (s *LanguageService) List(ctx context.Context, req *paginationV1.PagingRequest) (*dictV1.ListLanguageResponse, error) {
	return s.repo.List(ctx, req)
}
