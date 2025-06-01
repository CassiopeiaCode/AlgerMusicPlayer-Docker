#!/bin/bash

# 调试脚本 - 帮助排查构建和运行问题

echo "🔍 AlgerMusicPlayer Docker 调试工具"
echo "=================================="

# 检查 Docker 环境
echo "📋 检查 Docker 环境..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行"
    exit 1
fi

echo "✅ Docker 环境正常"

# 显示系统信息
echo ""
echo "💻 系统信息:"
echo "   Docker 版本: $(docker --version)"
echo "   Docker Compose 版本: $(docker-compose --version 2>/dev/null || echo 'Not installed')"
echo "   可用磁盘空间: $(df -h . | tail -1 | awk '{print $4}')"

# 检查端口占用
echo ""
echo "🔌 检查端口占用:"
if netstat -tuln 2>/dev/null | grep -q ":3000 "; then
    echo "⚠️  端口 3000 已被占用"
    echo "   占用进程: $(lsof -ti:3000 2>/dev/null || echo '未知')"
else
    echo "✅ 端口 3000 可用"
fi

# 检查现有容器
echo ""
echo "📦 现有容器状态:"
docker ps -a --filter "name=alger-music-player" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 检查镜像
echo ""
echo "🖼️  现有镜像:"
docker images | grep alger-music-player

# 提供操作选项
echo ""
echo "🛠️  可用操作:"
echo "   1. 清理现有容器和镜像"
echo "   2. 重新构建镜像"
echo "   3. 查看构建日志"
echo "   4. 查看运行日志"
echo "   5. 进入容器调试"
echo "   6. 测试网络连接"
echo ""

read -p "请选择操作 (1-6, 其他键退出): " choice

case $choice in
    1)
        echo "🧹 清理现有容器和镜像..."
        docker-compose down
        docker rmi alger-music-player:latest 2>/dev/null || true
        docker system prune -f
        echo "✅ 清理完成"
        ;;
    2)
        echo "🔨 重新构建镜像..."
        docker-compose build --no-cache
        ;;
    3)
        echo "📝 构建日志 (最后 50 行):"
        docker-compose logs --tail=50 alger-music-player || echo "无日志或容器未运行"
        ;;
    4)
        echo "📊 运行日志:"
        docker-compose logs -f alger-music-player
        ;;
    5)
        echo "🐚 进入容器..."
        docker exec -it alger-music-player /bin/sh || echo "容器未运行或无法连接"
        ;;
    6)
        echo "🌐 测试网络连接..."
        echo "测试 GitHub 连接:"
        curl -I https://github.com/algerkong/AlgerMusicPlayer --max-time 10
        echo "测试本地服务:"
        curl -I http://localhost:3000 --max-time 5 || echo "本地服务未响应"
        ;;
    *)
        echo "👋 退出调试工具"
        ;;
esac
