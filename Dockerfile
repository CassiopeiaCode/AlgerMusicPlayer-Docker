# 使用 Node.js 基础镜像
FROM node:18-alpine

# 安装必要的系统依赖并清理缓存
RUN apk add --no-cache git python3 make g++ curl supervisor && \
    rm -rf /var/cache/apk/*

# 设置工作目录
WORKDIR /app

# 复制配置文件和启动脚本
COPY supervisord.conf entrypoint.sh ./
RUN chmod +x entrypoint.sh

# 设置环境变量
ENV NODE_ENV=development

# 暴露端口
EXPOSE 5173 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:5173 || exit 1

# 创建数据目录挂载点
VOLUME ["/data", "/app/frontend", "/app/api"]

# 使用入口脚本启动
CMD ["./entrypoint.sh"]
