FROM golang:1.25-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o /qwe1-agent ./cmd/qwe1-agent

FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /qwe1-agent /usr/local/bin/qwe1-agent

RUN addgroup -S qwe1 && adduser -S qwe1 -G qwe1

USER qwe1

EXPOSE 9443

ENTRYPOINT ["qwe1-agent"]
CMD ["--config", "/etc/qwe1/config.yaml"]
