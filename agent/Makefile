.PHONY: build run test lint clean docker

# Build the agent
build:
	go build -o bin/qwe1-agent ./cmd/qwe1-agent

# Run the agent
run:
	go run ./cmd/qwe1-agent

# Run tests
test:
	go test ./...

# Run linter
lint:
	go vet ./...
	staticcheck ./...

# Clean build artifacts
clean:
	rm -rf bin/

# Build Docker image
docker:
	docker build -t qwe1/agent .

# Run Docker container
docker-run:
	docker run -d \
		--name qwe1-agent \
		--restart unless-stopped \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-p 9443:9443 \
		qwe1/agent

# Generate enrollment token
enroll:
	go run ./cmd/qwe1-agent --enroll

# Cross-compile for different platforms
build-all:
	GOOS=linux GOARCH=amd64 go build -o bin/qwe1-agent-linux-amd64 ./cmd/qwe1-agent
	GOOS=linux GOARCH=arm64 go build -o bin/qwe1-agent-linux-arm64 ./cmd/qwe1-agent
	GOOS=linux GOARCH=arm GOARM=7 go build -o bin/qwe1-agent-linux-armv7 ./cmd/qwe1-agent
	GOOS=darwin GOARCH=arm64 go build -o bin/qwe1-agent-darwin-arm64 ./cmd/qwe1-agent
	GOOS=darwin GOARCH=amd64 go build -o bin/qwe1-agent-darwin-amd64 ./cmd/qwe1-agent

# Development helpers
dev:
	go run ./cmd/qwe1-agent --config config.dev.yaml
