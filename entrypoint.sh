#!/bin/sh

# 设置错误时退出
set -e

echo "🚀 初始化应用..."

# 检查并创建必要的目录
mkdir -p /var/log/supervisor /etc/supervisor/conf.d /data

# 复制 supervisor 配置
cp /app/supervisord.conf /etc/supervisor/conf.d/

# 检查是否是开发模式（通过挂载的目录判断）
if [ "$DEV_MODE" = "true" ] && [ -d "/app/frontend" ] && [ ! -f "/app/frontend/.git/config" ]; then
    echo "🔧 开发模式：检测到本地代码目录，但无 Git 仓库"
    echo "📥 初始化前端代码..."
    rm -rf /app/frontend/*
    git clone https://github.com/algerkong/AlgerMusicPlayer.git /tmp/frontend
    cp -r /tmp/frontend/* /app/frontend/
    rm -rf /tmp/frontend
fi

if [ "$DEV_MODE" = "true" ] && [ -d "/app/api" ] && [ ! -f "/app/api/.git/config" ]; then
    echo "🔧 开发模式：检测到本地代码目录，但无 Git 仓库"
    echo "📥 初始化API代码..."
    rm -rf /app/api/*
    git clone https://github.com/nooblong/NeteaseCloudMusicApiBackup.git /tmp/api
    cp -r /tmp/api/* /app/api/
    rm -rf /tmp/api
fi

# 如果代码目录不存在，则克隆代码（非开发模式或首次运行）
if [ ! -d "/app/frontend/.git" ]; then
    echo "📥 克隆前端代码..."
    git clone https://github.com/algerkong/AlgerMusicPlayer.git /app/frontend
fi

if [ ! -d "/app/api/.git" ]; then
    echo "📥 克隆API代码..."
    git clone https://github.com/nooblong/NeteaseCloudMusicApiBackup.git /app/api
fi

# 安装依赖（如果 node_modules 不存在）
if [ ! -d "/app/frontend/node_modules" ]; then
    echo "📦 安装前端依赖..."
    cd /app/frontend && npm install
fi

if [ ! -d "/app/api/node_modules" ]; then
    echo "📦 安装API依赖..."
    cd /app/api && npm install
fi

echo "✅ 初始化完成，启动服务..."

# 启动 supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
