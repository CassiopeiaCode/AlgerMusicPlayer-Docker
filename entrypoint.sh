#!/bin/sh

# 设置错误时退出
set -e

echo "🚀 初始化应用..."

# 检查并创建必要的目录
mkdir -p /var/log/supervisor /etc/supervisor/conf.d /data

# 复制 supervisor 配置
cp /app/supervisord.conf /etc/supervisor/conf.d/

# 如果前端目录不存在或为空，则克隆代码
if [ ! -d "/app/frontend" ] || [ ! -f "/app/frontend/package.json" ]; then
    echo "📥 克隆前端代码..."
    # 确保目标目录为空或不存在，避免删除挂载的卷
    if mountpoint -q /app/frontend; then
        echo "⚠️ /app/frontend 是一个挂载点，跳过删除操作..."
    else
        rm -rf /app/frontend
    fi
    git clone https://github.com/algerkong/AlgerMusicPlayer.git /app/frontend || {
        echo "❌ 前端代码克隆失败"
        exit 1
    }
fi

# 如果 API 目录不存在或为空，则克隆代码
if [ ! -d "/app/api" ] || [ ! -f "/app/api/package.json" ]; then
    echo "📥 克隆API代码..."
    # 确保目标目录为空或不存在，避免删除挂载的卷
    if mountpoint -q /app/api; then
        echo "⚠️ /app/api 是一个挂载点，跳过删除操作..."
    else
        rm -rf /app/api
    fi
    git clone https://github.com/nooblong/NeteaseCloudMusicApiBackup.git /app/api || {
        echo "❌ API代码克隆失败"
        exit 1
    }
fi

# 安装前端依赖（如果 node_modules 不存在）
if [ ! -d "/app/frontend/node_modules" ]; then
    echo "📦 安装前端依赖..."
    cd /app/frontend && npm install || {
        echo "❌ 前端依赖安装失败"
        exit 1
    }
fi

# 安装 API 依赖（如果 node_modules 不存在）
if [ ! -d "/app/api/node_modules" ]; then
    echo "📦 安装API依赖..."
    cd /app/api && npm install || {
        echo "❌ API依赖安装失败"
        exit 1
    }
fi

echo "✅ 初始化完成，启动服务..."

# 启动 supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
