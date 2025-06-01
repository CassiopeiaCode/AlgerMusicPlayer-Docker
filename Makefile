.PHONY: help build build-prod dev dev-hot stop clean logs restart

# 默认目标
help:
	@echo "🎵 AlgerMusicPlayer Docker 管理命令:"
	@echo ""
	@echo "  make build      - 构建开发环境镜像"
	@echo "  make build-prod - 构建生产环境镜像"
	@echo "  make dev        - 启动开发环境"
	@echo "  make dev-hot    - 启动开发环境(代码热重载)"
	@echo "  make stop       - 停止服务"
	@echo "  make restart    - 重启服务"
	@echo "  make logs       - 查看日志"
	@echo "  make clean      - 清理镜像和容器"
	@echo ""

# 构建开发镜像
build:
	@echo "📦 构建开发环境镜像..."
	docker-compose build --no-cache

# 构建生产镜像
build-prod:
	@echo "📦 构建生产环境镜像..."
	docker build -f Dockerfile.prod -t alger-music-player:prod .

# 启动开发环境
dev:
	@echo "🚀 启动开发环境..."
	docker-compose up -d
	@echo "🌐 前端: http://localhost:5173"
	@echo "🌐 API:  http://localhost:3000"

# 启动开发环境(热重载)
dev-hot:
	@echo "🚀 启动开发环境(代码热重载)..."
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
	@echo "🌐 前端: http://localhost:5173"
	@echo "🌐 API:  http://localhost:3000"

# 停止服务
stop:
	@echo "⏹️  停止服务..."
	docker-compose down

# 重启服务
restart: stop dev

# 查看日志
logs:
	docker-compose logs -f

# 清理
clean:
	@echo "🧹 清理镜像和容器..."
	docker-compose down -v --rmi all
	docker system prune -f
