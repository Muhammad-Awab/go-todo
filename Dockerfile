# ---------- Build Stage ----------
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
COPY .env.example .env

RUN go mod download

COPY . .

RUN go build -o main .

# ---------- Runtime Stage ----------
FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache bash netcat-openbsd

COPY --from=builder /app/main .
COPY --from=builder /app/views ./views
COPY --from=builder /app/.env .env

# Copy wait-for-it script
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

EXPOSE 4040

# Wait for MySQL before starting the app
CMD ["/bin/bash", "-c", "/wait-for-it.sh my-mysql:3306 -- ./main"]
