package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	adminV1 "go-wind-ledger/api/gen/go/admin/service/v1"
	storageV1 "go-wind-ledger/api/gen/go/storage/service/v1"
)

type FileTransferService struct {
	adminV1.FileTransferServiceHTTPServer
	log *log.Helper
}

func NewFileTransferService(ctx *bootstrap.Context) *FileTransferService {
	return &FileTransferService{
		log: ctx.NewLoggerHelper("file-transfer/service/admin-service"),
	}
}

func (s *FileTransferService) DownloadFile(ctx context.Context, req *storageV1.DownloadFileRequest) (*storageV1.DownloadFileResponse, error) {
	return &storageV1.DownloadFileResponse{}, nil
}

func (s *FileTransferService) PostUploadFile(ctx context.Context, req *storageV1.UploadFileRequest) (*storageV1.UploadFileResponse, error) {
	return &storageV1.UploadFileResponse{}, nil
}

func (s *FileTransferService) PutUploadFile(ctx context.Context, req *storageV1.UploadFileRequest) (*storageV1.UploadFileResponse, error) {
	return &storageV1.UploadFileResponse{}, nil
}
