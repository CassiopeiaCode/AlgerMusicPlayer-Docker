#!/bin/sh
set -e

echo "🚀 启动生产环境..."

# 启动 supervisor 管理 nginx 和 API
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
