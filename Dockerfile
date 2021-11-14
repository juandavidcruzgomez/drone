FROM golang:1.14.15 as builder
# first (build) stage

ENV GOARCH amd64
ENV GOOS linux

RUN apt-get update
RUN apt-get install -y wget gcc make g++ build-essential ca-certificates git bzr libsqlite3-dev sqlite3

WORKDIR /app
COPY . .
RUN go mod download
RUN go build -ldflags "-extldflags \"-static\"" -o release/linux/${GOARCH}/drone-server -tags "oss nolimit" ./cmd/drone-server

# final (target) stage

FROM alpine:3.10
ENV GOARCH amd64
COPY --from=builder /app/release/linux/${GOARCH} /app

EXPOSE 8080

CMD ["/app/drone-server"]
