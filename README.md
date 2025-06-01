# AlgerMusicPlayer-Docker

🎵 Alger Music Player 的 Docker 版本

> 基于 [algerkong/AlgerMusicPlayer](https://github.com/algerkong/AlgerMusicPlayer) 项目构建的 Docker 容器化版本

## 项目简介

AlgerMusicPlayer 是一个功能强大的第三方音乐播放器，支持网易云音乐、本地音乐播放、歌词显示、音乐下载等功能。本项目将其容器化，方便在各种环境中部署和使用。

## 主要特性

- 🎵 音乐推荐和播放
- 🔐 网易云账号登录与同步
- 📝 播放历史记录和歌曲收藏管理
- 🎨 沉浸式歌词显示和多主题支持
- 🎼 高品质音乐和音乐下载
- 🚀 全平台适配的 Web 版本
- 🔌 内置网易云音乐 API 服务
- 📁 本地数据存储支持
- 🔧 开发模式支持，支持热重载

## 快速开始

### 方式一：使用构建脚本

#### Windows 用户
```cmd
build.bat
```

#### Linux/macOS 用户
```bash
chmod +x build.sh
./build.sh
```

### 方式二：手动构建

1. **克隆项目**
```bash
git clone https://github.com/CassiopeiaCode/AlgerMusicPlayer-Docker
cd AlgerMusicPlayer-Docker
```

2. **构建并启动服务**
```bash
docker-compose up -d --build
```

3. **访问应用**
- 前端界面 (开发模式): http://localhost:5173
- API 服务: http://localhost:3000
- 数据存储：./data 目录（自动创建）
- 支持热重载和实时更新

## Docker Compose 配置

默认配置：
- **前端端口**: 5173:5173 (开发模式，支持热重载)
- **API 端口**: 3000:3000
- **数据目录**: ./data (本地目录映射)
- **运行模式**: development (开发模式)
- **重启策略**: unless-stopped
- **网络**: 自定义桥接网络

### 自定义端口

如果需要修改端口，编辑 `docker-compose.yml` 文件：

```yaml
ports:
  - "8080:5173"   # 前端端口：将 5173 改为你想要的端口
  - "8081:3000"   # API 端口：将 3000 改为你想要的端口
```

### 数据持久化

项目使用本地 `./data` 目录存储数据，包括：
- 用户配置文件
- 播放历史
- 缓存文件
- 其他应用数据

### 开发模式特性

- ✅ **热重载**: 代码更改会自动反映到浏览器
- ✅ **实时更新**: 无需重新构建容器
- ✅ **开发工具**: 包含完整的开发环境
- ✅ **调试支持**: 便于开发和调试

## 手动 Docker 命令

如果不想使用 docker-compose，也可以直接使用 Docker 命令：

```bash
# 构建镜像
docker build -t alger-music-player .

# 运行容器
docker run -d \
  --name alger-music-player \
  -p 5173:5173 \
  -p 3000:3000 \
  -v ./data:/data \
  --restart unless-stopped \
  alger-music-player
```

## 管理容器

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f alger-music-player

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 更新并重新构建
docker-compose up -d --build
```

## 故障排除

### 1. 构建失败
- 确保 Docker 正在运行
- 检查网络连接（需要从 GitHub 克隆项目）
- 尝试清理 Docker 缓存：`docker system prune -a`

### 2. 无法访问应用
- 检查端口是否被占用：`netstat -an | grep 3000`
- 确保防火墙允许访问该端口
- 查看容器日志：`docker-compose logs alger-music-player`

### 3. 音乐播放问题
- 由于浏览器安全策略，部分功能可能需要 HTTPS
- 某些音源可能需要额外的 API 服务支持

## 目录结构

```
AlgerMusicPlayer-Docker/
├── Dockerfile              # Docker 构建文件
├── docker-compose.yml      # Docker Compose 配置
├── nginx.conf              # Nginx 配置文件
├── build.sh                # Linux/macOS 构建脚本
├── build.bat               # Windows 构建脚本
├── .dockerignore           # Docker 忽略文件
└── README.md               # 项目说明
```

## 技术栈

- **前端**: Vue 3 + TypeScript + Electron (Web 版本)
- **构建工具**: Electron Vite
- **容器**: Docker + Nginx
- **音乐 API**: 网易云音乐 API

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目遵循原项目的许可证。请注意：

⚠️ **免责声明**: 本软件仅用于学习交流，禁止用于商业用途，否则后果自负。

## 相关链接

- [原始项目](https://github.com/algerkong/AlgerMusicPlayer)
- [在线演示](http://music.alger.fun/)
- [项目文档](https://www.yuque.com/alger-pfg5q/ip4f1a/bmgmfmghnhgwghkm)
