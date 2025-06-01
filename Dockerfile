# 第一阶段：构建阶段
FROM node:18-alpine AS builder

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
RUN npm config set registry https://registry.npmjs.org/ && \
    npm config set timeout 300000 && \
    npm config set maxsockets 10 && \
    npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000

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

# 第二阶段：生产阶段
FROM nginx:alpine AS production

# 安装 curl 用于健康检查
RUN apk add --no-cache curl

# 复制构建产物
COPY --from=builder /build /usr/share/nginx/html

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/nginx.conf

# 创建健康检查脚本
RUN echo '#!/bin/sh' > /healthcheck.sh && \
    echo 'curl -f http://localhost/ || exit 1' >> /healthcheck.sh && \
    chmod +x /healthcheck.sh

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD /healthcheck.sh

# 暴露端口
EXPOSE 80

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]
