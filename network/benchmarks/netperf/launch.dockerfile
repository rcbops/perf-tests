FROM golang:1.10 AS builder

RUN mkdir /build
ADD . /build/
ADD ./vendor/ /go/src/
WORKDIR /build

RUN CGO_ENABLED=0 GOOS=linux \
	go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o launch .

FROM scratch
COPY --from=builder /build/launch /usr/local/bin/launch

WORKDIR /app
CMD ["/usr/local/bin/launch"]
