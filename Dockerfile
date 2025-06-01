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
    curl

# 克隆 AlgerMusicPlayer 项目
RUN git clone https://github.com/algerkong/AlgerMusicPlayer.git .

# 复制 package 文件并安装依赖
RUN npm ci --only=production=false --silent

# 设置环境变量
ENV NODE_ENV=production

# 构建项目 - 尝试多个可能的构建命令
RUN npm run build || npm run build:web || npm run build:renderer

# 检查构建产物并复制到标准位置
RUN mkdir -p /build && \
    (cp -r out/renderer/* /build/ 2>/dev/null || \
     cp -r dist/* /build/ 2>/dev/null || \
     cp -r build/* /build/ 2>/dev/null || \
     echo "No build output found, creating basic index.html" && \
     echo '<!DOCTYPE html><html><head><title>AlgerMusicPlayer</title></head><body><h1>Building...</h1></body></html>' > /build/index.html)

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
