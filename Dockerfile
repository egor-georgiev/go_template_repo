ARG GOTAG=1.25.6 # the default value is here to avoid warnings, always passed from Makefile explicitly
FROM --platform=${BUILDPLATFORM} golang:${GOTAG} AS builder
ARG TARGETOS TARGETARCH APP_NAME
ENV GOOS=${TARGETOS} GOARCH=${TARGETARCH} APP_NAME=${APP_NAME}
WORKDIR /code
COPY go.* ./
# COPY go.sum go.mod ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download -x
COPY main.go .

FROM builder AS build
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -trimpath -ldflags="-s -w" -o "${APP_NAME}" .

FROM builder AS build_dev
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -cover -covermode atomic -o "${APP_NAME}_dev" .

FROM scratch AS final
COPY --from=build /code/ .

FROM scratch AS final_dev
COPY --from=build_dev /code/ .

