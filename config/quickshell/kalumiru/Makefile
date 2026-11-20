.PHONY: backend check-backend

backend:
	cd backend && go build -o kalumirud ./cmd/kalumirud

check-backend:
	cd backend && go test ./...
	cd backend && go vet ./...
