FROM golang:1.10-alpine AS builder

ADD https://github.com/golang/dep/releases/download/v0.4.1/dep-linux-amd64 /usr/bin/dep
RUN chmod +x /usr/bin/dep

WORKDIR $GOPATH/src/github.com/gladiusio/gladius-controld
COPY . ./

RUN apk add --no-cache make gcc musl-dev linux-headers git

RUN make dependencies
RUN make docker

ENV GLADIUSBASE=/gladius
RUN mkdir -p ${GLADIUSBASE}/wallet
RUN mkdir -p ${GLADIUSBASE}/keys
RUN touch ${GLADIUSBASE}/gladius-controld.toml

########################################

FROM alpine:latest
RUN apk add --no-cache ca-certificates

COPY --from=builder /gladius/wallet /gladius/wallet
COPY --from=builder /gladius/keys /gladius/keys
COPY --from=builder /gladius/gladius-controld.toml /gladius/gladius-controld.toml

COPY --from=builder /gladius-controld ./
ENTRYPOINT ["./gladius-controld"]