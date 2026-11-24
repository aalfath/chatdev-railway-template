# ChatDev (DevAll) web console: the upstream Vue UI built as static files and
# served by Caddy, which adds a login and proxies /api and /ws to the private backend.
ARG CHATDEV_REF=v2.2.0
ARG CHATDEV_COMMIT=3c72d860d2553f05129b7dff0fd4efdde5b01d2f

FROM alpine/git:v2.54.1@sha256:29cff25811f790b9f72fc266bf8009a5a911714c0e03c31c47339c50909d9aef AS src
ARG CHATDEV_REF
ARG CHATDEV_COMMIT
RUN git clone --quiet --depth 1 --branch "$CHATDEV_REF" https://github.com/OpenBMB/ChatDev /src \
 && test "$(git -C /src rev-parse HEAD)" = "$CHATDEV_COMMIT"

FROM node:24.22.3-alpine@sha256:116b800c3754b440ee0aa3ed2f20f5bf3d99a554bfd9adeea09ea8017f6e85f5 AS build
WORKDIR /app
COPY --from=src /src/frontend/package.json /src/frontend/package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY --from=src /src/frontend/ ./
ENV VITE_API_BASE_URL=
RUN npm run build

FROM caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0
COPY --from=build /app/dist /srv
COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh /usr/local/bin/chatdev-web
RUN chmod 0755 /usr/local/bin/chatdev-web
ENV PORT=8080 BACKEND_PORT=6400 CHATDEV_USERNAME=admin
EXPOSE 8080
CMD ["/usr/local/bin/chatdev-web"]
