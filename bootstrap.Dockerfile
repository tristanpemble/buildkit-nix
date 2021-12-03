ARG GOLANG_IMAGE=golang:1.17.3-alpine@sha256:a207b29286084e7342286de809756f61558b00b81f794406399027631e0dba8b
# Mirrored from "docker.io/nixos/nix:2.3.12@sha256:d9bb3b85b846eb0b6c5204e0d76639dff72c7871fb68f5d4edcfbb727f8a5653" (amd64-only) to avoid Docker Hub rate limit
ARG NIX_IMAGE=ghcr.io/stargz-containers/nixos/nix:2.3.12-org@sha256:d9bb3b85b846eb0b6c5204e0d76639dff72c7871fb68f5d4edcfbb727f8a5653

FROM ${GOLANG_IMAGE} AS build
WORKDIR /src
ENV CGO_ENABLED=0
RUN --mount=target=. --mount=target=/root/.cache,type=cache --mount=target=/go/pkg,type=cache \
  go build -trimpath -ldflags "-s -w" -o /out/buildkit-nix ./cmd/buildkit-nix

FROM scratch
COPY --from=build /out/ /
ARG NIX_IMAGE
ENV NIX_IMAGE=${NIX_IMAGE}
LABEL moby.buildkit.frontend.network.none="true"
ENTRYPOINT ["/buildkit-nix", "frontend"]