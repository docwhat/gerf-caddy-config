##############################
# Aliases to unify versioning.
FROM caddy:2-builder AS caddy-builder
FROM caddy:2 AS caddy

#########################
# Add additional modules.
FROM caddy-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/linode

######################
# Actual image to use.
FROM caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN set -eux; \
    addgroup -g 1000 -S caddy; \
    adduser -u 1000 -D -S -G caddy caddy

# Useful for debugging.
# RUN apk add --no-cache jq curl

USER caddy

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost

CMD [ "caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile", "--envfile", "/run/secrets/caddy_envfile" ]
