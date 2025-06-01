# AlgerMusicPlayer-Docker

基于 [algerkong/AlgerMusicPlayer](https://github.com/algerkong/AlgerMusicPlayer) 的 Docker 容器化版本。

## 特性

- 使用 Docker 容器化部署
- 支持开发环境和生产环境
- 前端界面与 API 服务整合
- 代码热重载支持
- 数据持久化

## 快速开始

### 开发环境

```bash
# 构建和启动开发环境
make init-dev

# 代码热重载开发环境
make dev-hot

# 查看日志
make logs
```

### 生产环境

```bash
# 构建和启动生产环境
make init-prod

# 查看日志
make logs-prod
```

## 访问地址

| 服务 | 开发环境 | 生产环境 |
|------|----------|----------|
| 前端界面 | http://localhost:5173 | http://localhost |
| API 服务 | http://localhost:3000 | http://localhost/api |

## 管理命令

```bash
make help          # 显示所有可用命令
make build         # 构建开发镜像
make build-prod    # 构建生产镜像
make dev           # 启动开发环境
make dev-hot       # 启动热重载环境
make stop          # 停止服务
make restart       # 重启服务
make logs          # 查看开发环境日志
make logs-prod     # 查看生产环境日志
make clean-dev     # 清理开发环境
make clean-prod    # 清理生产环境
make clean-all     # 彻底清理所有环境
```

## 项目结构

```
AlgerMusicPlayer-Docker/
├── Dockerfile              # 开发环境
├── Dockerfile.prod         # 生产环境
├── docker-compose.yml      # 基础配置
├── docker-compose.dev.yml  # 开发环境配置
├── docker-compose.prod.yml # 生产环境配置
├── supervisord.conf        # 开发环境进程管理
├── supervisord.prod.conf   # 生产环境进程管理
├── entrypoint.sh           # 开发环境启动脚本
├── entrypoint.prod.sh      # 生产环境启动脚本
├── Makefile                # 管理命令
└── nginx.conf              # Nginx配置
```
