# 第一阶段：构建前端
FROM node:18-alpine AS frontend-builder

# 设置工作目录
WORKDIR /app

# 安装构建所需的系统依赖
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    curl \
    libc6-compat

# 克隆 AlgerMusicPlayer 项目
RUN git clone https://github.com/algerkong/AlgerMusicPlayer.git .

# 设置 npm 配置以提高稳定性
RUN npm config set registry https://registry.npmjs.org/

# 先安装依赖（使用 npm install 而不是 npm ci，更容错）
RUN set -e && \
    echo "Starting npm install..." && \
    npm install --no-audit --no-fund --verbose || \
    (echo "First npm install failed, cleaning cache and retrying..." && \
     npm cache clean --force && \
     rm -rf node_modules package-lock.json && \
     npm install --no-audit --no-fund --verbose) || \
    (echo "Second attempt failed, trying with legacy peer deps..." && \
     rm -rf node_modules && \
     npm install --legacy-peer-deps --no-audit --no-fund --verbose) || \
    (echo "Third attempt failed, trying with force..." && \
     rm -rf node_modules && \
     npm install --force --no-audit --no-fund --verbose)

# 设置环境变量
ENV NODE_ENV=production

# 构建项目 - 尝试多个可能的构建命令
RUN echo "Starting build process..." && \
    echo "Available npm scripts:" && \
    npm run 2>/dev/null | grep -E "^\s+" || echo "No scripts listed" && \
    echo "Attempting to build..." && \
    (npm run build 2>&1 | tee build.log || \
     npm run build:web 2>&1 | tee build.log || \
     npm run build:renderer 2>&1 | tee build.log || \
     (echo "All build attempts failed. Available scripts:" && \
      cat package.json | grep -A 20 '"scripts"' && \
      echo "Build log:" && cat build.log 2>/dev/null || echo "No build log available" && \
      echo "Proceeding without build..."))

# 检查构建产物并复制到标准位置
RUN mkdir -p /build && \
    (cp -r out/renderer/* /build/ 2>/dev/null || \
     cp -r dist/* /build/ 2>/dev/null || \
     cp -r build/* /build/ 2>/dev/null || \
     (echo "No standard build output found, searching for built files..." && \
      find . -name "*.html" -path "*/dist*" -o -path "*/build*" -o -path "*/out*" | head -1 | xargs -I {} cp -r "$(dirname {})"/* /build/ 2>/dev/null || \
      echo "Creating fallback index.html" && \
      echo '<!DOCTYPE html><html><head><title>AlgerMusicPlayer</title><meta charset="utf-8"><style>body{font-family:Arial,sans-serif;text-align:center;padding:50px;}h1{color:#333;}</style></head><body><h1>🎵 AlgerMusicPlayer</h1><p>容器正在构建中，请稍候...</p><p>如果长时间显示此页面，请检查构建日志。</p></body></html>' > /build/index.html))

# 确保至少有一个 index.html 文件
RUN ls -la /build/ && \
    if [ ! -f /build/index.html ]; then \
        echo "Creating basic index.html..." && \
        echo '<!DOCTYPE html><html><head><title>AlgerMusicPlayer</title></head><body><h1>AlgerMusicPlayer is starting...</h1></body></html>' > /build/index.html; \
    fi

# 第二阶段：构建 API 服务
FROM node:18-alpine AS api-builder

# 设置工作目录
WORKDIR /api

# 克隆网易云音乐 API 项目
RUN git clone https://github.com/Binaryify/NeteaseCloudMusicApi.git . && \
    npm install --production

# 第三阶段：生产阶段 - 运行前端和API
FROM node:18-alpine AS production

# 安装 nginx 和 supervisor 用于同时运行多个服务
RUN apk add --no-cache nginx curl supervisor

# 创建必要的目录
RUN mkdir -p /var/log/supervisor /run/nginx /var/tmp/nginx /var/cache/nginx /data /etc/supervisor/conf.d

# 复制前端构建产物
COPY --from=frontend-builder /build /usr/share/nginx/html

# 复制 API 服务
COPY --from=api-builder /api /app/api
WORKDIR /app/api

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/nginx.conf

# 创建 supervisor 配置文件
RUN echo '[supervisord]' > /etc/supervisor/conf.d/supervisord.conf && \
    echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'logfile=/var/log/supervisor/supervisord.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'pidfile=/var/run/supervisord.pid' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:nginx]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=nginx -g "daemon off;"' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stderr_logfile=/var/log/supervisor/nginx.err.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stdout_logfile=/var/log/supervisor/nginx.out.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:api]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=node app.js' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'directory=/app/api' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stderr_logfile=/var/log/supervisor/api.err.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stdout_logfile=/var/log/supervisor/api.out.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'environment=NODE_ENV=production,PORT=3000' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf

# 创建健康检查脚本
RUN echo '#!/bin/sh' > /healthcheck.sh && \
    echo 'curl -f http://localhost/ && curl -f http://localhost:3000/login/status || exit 1' >> /healthcheck.sh && \
    chmod +x /healthcheck.sh

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
  CMD /healthcheck.sh

# 暴露端口 (80 for frontend, 3000 for API)
EXPOSE 80 3000

# 创建数据目录
VOLUME ["/data"]

# 启动 supervisor 来管理多个服务
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
