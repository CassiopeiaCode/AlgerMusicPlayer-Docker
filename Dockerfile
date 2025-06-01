# 使用 Node.js 基础镜像
FROM node:18-alpine

# 安装必要的系统依赖
RUN apk add --no-cache git python3 make g++ curl supervisor

# 创建应用目录
WORKDIR /app

# 克隆 AlgerMusicPlayer 项目
RUN git clone https://github.com/algerkong/AlgerMusicPlayer.git frontend

# 克隆 API 项目
RUN git clone https://github.com/Binaryify/NeteaseCloudMusicApi.git api

# 安装前端依赖
WORKDIR /app/frontend
RUN npm install

# 安装 API 依赖
WORKDIR /app/api
RUN npm install

# 创建 supervisor 配置目录
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d

# 创建 supervisor 配置文件
RUN echo '[supervisord]' > /etc/supervisor/conf.d/supervisord.conf && \
    echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'logfile=/var/log/supervisor/supervisord.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'pidfile=/var/run/supervisord.pid' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:frontend]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=npm run dev' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'directory=/app/frontend' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stderr_logfile=/var/log/supervisor/frontend.err.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stdout_logfile=/var/log/supervisor/frontend.out.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:api]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=npm start' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'directory=/app/api' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stderr_logfile=/var/log/supervisor/api.err.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stdout_logfile=/var/log/supervisor/api.out.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'environment=NODE_ENV=development' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf

# 创建数据目录
RUN mkdir -p /data

# 设置环境变量
ENV NODE_ENV=development

# 暴露端口
EXPOSE 5173 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:5173 || exit 1

# 创建数据目录挂载点
VOLUME ["/data"]

# 启动 supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
