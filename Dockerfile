# Use an official lightweight base image with make installed
FROM alpine:latest AS builder

RUN apk add --no-cache make gcc musl-dev curl bash coreutils file
ENV GO_VERSION=1.23.2
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"


# Set working directory inside container
WORKDIR /app

# Copy source code and Makefile
COPY . .

# Run make deps to install dependencies
RUN make deps
RUN make build

FROM alpine:latest

EXPOSE 8080
WORKDIR /app
COPY --from=builder /app/vendor .
COPY --from=builder /app/static .
COPY --from=builder /app/website .

CMD ["/app/website"]