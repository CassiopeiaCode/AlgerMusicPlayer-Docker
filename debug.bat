@echo off
chcp 65001 >nul
echo 🔍 AlgerMusicPlayer Docker 调试工具
echo ==================================

REM 检查 Docker 环境
echo 📋 检查 Docker 环境...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker 未运行
    pause
    exit /b 1
)
echo ✅ Docker 环境正常

REM 显示系统信息
echo.
echo 💻 系统信息:
for /f "tokens=*" %%i in ('docker --version') do echo    Docker 版本: %%i
for /f "tokens=*" %%i in ('docker-compose --version 2^>nul') do echo    Docker Compose 版本: %%i

REM 检查端口占用
echo.
echo 🔌 检查端口占用:
netstat -an | find ":3000 " >nul
if %errorlevel% equ 0 (
    echo ⚠️  端口 3000 已被占用
) else (
    echo ✅ 端口 3000 可用
)

REM 检查现有容器
echo.
echo 📦 现有容器状态:
docker ps -a --filter "name=alger-music-player" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

REM 检查镜像
echo.
echo 🖼️  现有镜像:
docker images | find "alger-music-player"

REM 提供操作选项
echo.
echo 🛠️  可用操作:
echo    1. 清理现有容器和镜像
echo    2. 重新构建镜像
echo    3. 查看构建日志
echo    4. 查看运行日志
echo    5. 进入容器调试
echo    6. 测试网络连接
echo.

set /p choice=请选择操作 (1-6, 其他键退出): 

if "%choice%"=="1" (
    echo 🧹 清理现有容器和镜像...
    docker-compose down
    docker rmi alger-music-player:latest 2>nul
    docker system prune -f
    echo ✅ 清理完成
) else if "%choice%"=="2" (
    echo 🔨 重新构建镜像...
    docker-compose build --no-cache
) else if "%choice%"=="3" (
    echo 📝 构建日志 (最后 50 行):
    docker-compose logs --tail=50 alger-music-player
) else if "%choice%"=="4" (
    echo 📊 运行日志:
    docker-compose logs -f alger-music-player
) else if "%choice%"=="5" (
    echo 🐚 进入容器...
    docker exec -it alger-music-player /bin/sh
) else if "%choice%"=="6" (
    echo 🌐 测试网络连接...
    echo 测试 GitHub 连接:
    curl -I https://github.com/algerkong/AlgerMusicPlayer --max-time 10
    echo 测试本地服务:
    curl -I http://localhost:3000 --max-time 5
) else (
    echo 👋 退出调试工具
)

pause
