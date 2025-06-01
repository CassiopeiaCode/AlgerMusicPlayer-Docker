.PHONY: help build build-prod dev dev-hot prod stop stop-prod clean logs logs-prod restart restart-prod

# 默认目标
help:
	@echo "🎵 AlgerMusicPlayer Docker 管理命令:"
	@echo ""
	@echo "  🔧 开发环境:"
	@echo "    make build      - 构建开发环境镜像"
	@echo "    make dev        - 启动开发环境"
	@echo "    make dev-hot    - 启动开发环境(代码热重载)"
	@echo "    make logs       - 查看开发环境日志"
	@echo "    make stop       - 停止开发环境"
	@echo "    make restart    - 重启开发环境"
	@echo ""
	@echo "  🏭 生产环境:"
	@echo "    make build-prod - 构建生产环境镜像"
	@echo "    make prod       - 启动生产环境"
	@echo "    make logs-prod  - 查看生产环境日志"
	@echo "    make stop-prod  - 停止生产环境"
	@echo "    make restart-prod - 重启生产环境"
	@echo ""
	@echo "  🧹 清理:"
	@echo "    make clean      - 清理所有镜像和容器"
	@echo ""

# 构建开发镜像
build:
	@echo "📦 构建开发环境镜像..."
	docker-compose build --no-cache

# 构建生产镜像
build-prod:
	@echo "📦 构建生产环境镜像..."
	docker-compose -f docker-compose.prod.yml build --no-cache

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

# 启动生产环境
prod:
	@echo "🏭 启动生产环境..."
	docker-compose -f docker-compose.prod.yml up -d
	@echo "🌐 应用: http://localhost"

# 停止开发环境
stop:
	@echo "⏹️  停止开发环境..."
	docker-compose down

# 停止生产环境
stop-prod:
	@echo "⏹️  停止生产环境..."
	docker-compose -f docker-compose.prod.yml down

# 重启开发环境
restart: stop dev

# 重启生产环境
restart-prod: stop-prod prod

# 查看开发环境日志
logs:
	docker-compose logs -f

# 查看生产环境日志
logs-prod:
	docker-compose -f docker-compose.prod.yml logs -f

# 清理
clean:
	@echo "🧹 清理镜像和容器..."
	docker-compose down -v --rmi all
	docker system prune -f
