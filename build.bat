@echo off
echo 🚀 开始构建 AlgerMusicPlayer Docker 镜像...

REM 检查 Docker 是否运行
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker 未运行，请先启动 Docker
    pause
    exit /b 1
)

REM 构建镜像
echo 📦 构建 Docker 镜像...
docker-compose build --no-cache

if %errorlevel% equ 0 (
    echo ✅ 镜像构建成功！
    echo 🎵 运行以下命令启动服务：
    echo    docker-compose up -d
    echo 🌐 访问地址: http://localhost:3000
) else (
    echo ❌ 镜像构建失败
    pause
    exit /b 1
)

pause
