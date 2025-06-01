#!/bin/bash

echo "🚀 开始构建 AlgerMusicPlayer Docker 镜像..."

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 检查环境参数
BUILD_ENV=${1:-dev}

if [ "$BUILD_ENV" = "prod" ]; then
    echo "📦 构建生产环境镜像..."
    docker build -f Dockerfile.prod -t alger-music-player:prod .
    echo "✅ 生产镜像构建成功！"
    echo "🌐 运行命令: docker run -d -p 80:80 --name alger-music-player-prod alger-music-player:prod"
else
    echo "📦 构建开发环境镜像..."
    docker-compose build --no-cache
    echo "✅ 开发镜像构建成功！"
    echo "🎵 启动开发环境: docker-compose up -d"
    echo "🔧 启动开发环境(代码热重载): docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d"
    echo "🌐 访问地址:"
    echo "   前端: http://localhost:5173"
    echo "   API:  http://localhost:3000"
fi

echo "📁 数据目录: ./data"
