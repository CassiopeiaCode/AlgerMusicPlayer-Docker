@echo off
echo 🚀 开始构建 AlgerMusicPlayer Docker 镜像...

REM 检查 Docker 是否运行
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker 未运行，请先启动 Docker
    pause
    exit /b 1
)

REM 检查环境参数
set BUILD_ENV=%1
if "%BUILD_ENV%"=="" set BUILD_ENV=dev

if "%BUILD_ENV%"=="prod" (
    echo 📦 构建生产环境镜像...
    docker build -f Dockerfile.prod -t alger-music-player:prod .
    echo ✅ 生产镜像构建成功！
    echo 🌐 运行命令: docker run -d -p 80:80 --name alger-music-player-prod alger-music-player:prod
) else (
    echo 📦 构建开发环境镜像...
    docker-compose build --no-cache
    echo ✅ 开发镜像构建成功！
    echo 🎵 启动开发环境: docker-compose up -d
    echo 🔧 启动开发环境(代码热重载): docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
    echo 🌐 访问地址: 
    echo    前端: http://localhost:5173
    echo    API:  http://localhost:3000
)

echo 📁 数据目录: ./data
pause
