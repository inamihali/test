############################
# STEP 1 build executable binary
############################
FROM golang:1.15-alpine AS builder

# Create appuser
ENV USER=appuser
ENV UID=10001

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR /app

COPY go.mod ./

# Get dependancies - will also be cached if we won't change mod/sum
RUN go mod download

COPY . .

# Build the binary.
RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/golang-demo-app

############################
# STEP 2 build a small image
############################
FROM alpine:3.12.1 AS run-app

# Import the user and group files from the builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy our static executable.
COPY --from=builder /go/bin/golang-demo-app /go/bin/golang-demo-app

# Use an unprivileged user.
USER appuser:appuser

CMD [ "/go/bin/golang-demo-app" ]
