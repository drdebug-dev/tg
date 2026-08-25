FROM nginx:1.27-alpine

RUN apk add --no-cache openssl gettext \
    && rm -f /etc/nginx/conf.d/default.conf

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY nginx-http.conf.template /etc/nginx/nginx-http.conf.template
COPY docker-entrypoint.sh /usr/local/bin/telegram-bridge-entrypoint.sh
RUN chmod +x /usr/local/bin/telegram-bridge-entrypoint.sh

EXPOSE 80 443
ENTRYPOINT ["/usr/local/bin/telegram-bridge-entrypoint.sh"]
