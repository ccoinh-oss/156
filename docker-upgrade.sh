#!/bin/bash

# Docker 一键升级脚本 (使用 docker compose)
# 功能：停止 → 升级 → 重启

set -e

# 配置
COMPOSE_DIR="/root/cc"

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

log "开始升级流程..."

# 停止
log "停止容器..."
cd $COMPOSE_DIR
docker compose down --remove-orphans

# 升级
log "升级镜像..."
docker compose pull

# 重启
log "重启容器..."
docker compose up -d --build
sleep 3
docker compose ps

log "升级完成！"
