# tinyproxy-container-image

Container image for Tinyproxy. Runs inside a distroless image.

```bash
podman pull ghcr.io/zyrouge/tinyproxy:latest

podman run --rm \
    -p 8888:8888 \
    -v `pwd`/tinyproxy.conf:/etc/tinyproxy/tinyproxy.conf:ro \
    ghcr.io/zyrouge/tinyproxy:latest
```

# License

[Unlicense](./LICENSE)
