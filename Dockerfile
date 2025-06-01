FROM node:18-alpine

RUN apk add --no-cache git python3 make g++ curl supervisor && \
    rm -rf /var/cache/apk/*

WORKDIR /app

COPY supervisord.conf entrypoint.sh ./
RUN chmod +x entrypoint.sh

ENV NODE_ENV=development

EXPOSE 5173 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:5173 || exit 1

VOLUME ["/data", "/app/frontend", "/app/api"]

CMD ["./entrypoint.sh"]
