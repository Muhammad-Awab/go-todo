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
    
    EXPOSE 4040
    
    # Start the app directly
    CMD ["./main"]
    