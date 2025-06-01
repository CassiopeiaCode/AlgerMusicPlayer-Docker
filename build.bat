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
    docker-compose -f docker-compose.prod.yml build --no-cache
    if %errorlevel% equ 0 (
        echo ✅ 生产镜像构建成功！
        echo 🏭 启动命令: make prod
        echo 🌐 访问地址: http://localhost
    ) else (
        echo ❌ 生产镜像构建失败
        pause
        exit /b 1
    )
) else (
    echo 📦 构建开发环境镜像...
    docker-compose build --no-cache
    if %errorlevel% equ 0 (
        echo ✅ 开发镜像构建成功！
        echo 🎵 启动命令:
        echo    make dev      # 普通开发环境
        echo    make dev-hot  # 热重载开发环境
        echo 🌐 访问地址: 
        echo    前端: http://localhost:5173
        echo    API:  http://localhost:3000
    ) else (
        echo ❌ 开发镜像构建失败
        pause
        exit /b 1
    )
)

echo 📁 数据目录: ./data
pause
