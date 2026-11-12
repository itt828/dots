.PHONY: backend check-backend

backend:
	cd backend && go build -o qsittd ./cmd/qsittd

check-backend:
	cd backend && go test ./...
	cd backend && go vet ./...
