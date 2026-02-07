#!/bin/bash

# Docker 一键操作脚本
# 支持: 停止、升级、重启 Docker 容器

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
DOCKER_COMPOSE_DIR="/root/cc"
BACKUP_DIR="/root/cc/backup"
LOG_FILE="/root/cc/upgrade.log"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 日志函数
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[$timestamp]${NC} $1" | tee -a $LOG_FILE
}

# 停止 Docker 容器
stop_docker() {
    log "${YELLOW}正在停止 Docker 容器...${NC}"
    cd $DOCKER_COMPOSE_DIR

    # 使用 docker-compose 停止
    if [ -f "docker-compose.yml" ]; then
        docker-compose down --remove-orphans
        log "${GREEN}Docker Compose 容器已停止${NC}"
    fi

    # 如果有多个 compose 文件
    if [ -f "docker-compose.*.yml" ]; then
        for file in docker-compose.*.yml; do
            docker-compose -f "$file" down --remove-orphans
            log "${GREEN}$file 容器已停止${NC}"
        done
    fi

    log "${GREEN}所有 Docker 容器已停止${NC}"
}

# 升级 Docker 镜像
upgrade_docker() {
    log "${YELLOW}正在升级 Docker 镜像...${NC}"
    cd $DOCKER_COMPOSE_DIR

    # 创建备份
    local backup_time=$(date '+%Y%m%d_%H%M%S')
    if [ -f ".env" ]; then
        cp .env "$BACKUP_DIR/.env.$backup_time"
        log "${BLUE}已备份 .env 文件${NC}"
    fi

    # 拉取最新镜像
    if [ -f "docker-compose.yml" ]; then
        docker-compose pull
        log "${GREEN}Docker Compose 镜像已更新${NC}"
    fi

    # 如果有多个 compose 文件
    if [ -f "docker-compose.*.yml" ]; then
        for file in docker-compose.*.yml; do
            docker-compose -f "$file" pull
            log "${GREEN}$file 镜像已更新${NC}"
        done
    fi

    log "${GREEN}Docker 镜像升级完成${NC}"
}

# 重启 Docker 容器
restart_docker() {
    log "${YELLOW}正在重启 Docker 容器...${NC}"
    cd $DOCKER_COMPOSE_DIR

    # 构建并启动
    if [ -f "docker-compose.yml" ]; then
        docker-compose up -d --build
        log "${GREEN}Docker Compose 容器已重启${NC}"
    fi

    # 如果有多个 compose 文件
    if [ -f "docker-compose.*.yml" ]; then
        for file in docker-compose.*.yml; do
            docker-compose -f "$file" up -d --build
            log "${GREEN}$file 容器已重启${NC}"
        done
    fi

    # 等待容器启动
    sleep 5

    # 检查容器状态
    log "${YELLOW}检查容器运行状态...${NC}"
    docker-compose ps

    log "${GREEN}Docker 容器重启完成${NC}"
}

# 查看容器状态
status() {
    log "${YELLOW}当前 Docker 容器状态:${NC}"
    cd $DOCKER_COMPOSE_DIR
    docker-compose ps
}

# 查看日志
logs() {
    log "${YELLOW}查看 Docker 容器日志:${NC}"
    cd $DOCKER_COMPOSE_DIR
    docker-compose logs -f
}

# 主菜单
show_menu() {
    echo -e "\n${BLUE}======================================${NC}"
    echo -e "${BLUE}      Docker 一键操作脚本          ${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
    echo -e "${GREEN}1${NC}) 停止 Docker 容器"
    echo -e "${GREEN}2${NC}) 升级 Docker 镜像"
    echo -e "${GREEN}3${NC}) 重启 Docker 容器"
    echo -e "${GREEN}4${NC}) 一键完整升级 (停止→升级→重启)"
    echo -e "${GREEN}5${NC}) 查看容器状态"
    echo -e "${GREEN}6${NC}) 查看容器日志"
    echo -e "${GREEN}q${NC}) 退出"
    echo ""
    read -p "请选择操作 [1-6]: " choice
    echo ""
}

# 主程序
main() {
    # 清理旧的日志
    > $LOG_FILE

    while true; do
        show_menu

        case $choice in
            1)
                stop_docker
                ;;
            2)
                upgrade_docker
                ;;
            3)
                restart_docker
                ;;
            4)
                log "${GREEN}======================================${NC}"
                log "${GREEN}    开始一键完整升级流程          ${NC}"
                log "${GREEN}======================================${NC}"
                stop_docker
                upgrade_docker
                restart_docker
                log "${GREEN}======================================${NC}"
                log "${GREEN}    一键升级完成！               ${NC}"
                log "${GREEN}======================================${NC}"
                ;;
            5)
                status
                ;;
            6)
                logs
                ;;
            q|Q)
                log "退出脚本"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请重新输入${NC}"
                ;;
        esac

        echo ""
        read -p "按回车键继续..."
    done
}

# 检查是否在命令行参数模式
if [ "$1" == "--stop" ]; then
    stop_docker
elif [ "$1" == "--upgrade" ]; then
    upgrade_docker
elif [ "$1" == "--restart" ]; then
    restart_docker
elif [ "$1" == "--full" ]; then
    log "${GREEN}======================================${NC}"
    log "${GREEN}    开始一键完整升级流程          ${NC}"
    log "${GREEN}======================================${NC}"
    stop_docker
    upgrade_docker
    restart_docker
    log "${GREEN}======================================${NC}"
    log "${GREEN}    一键升级完成！               ${NC}"
    log "${GREEN}======================================${NC}"
elif [ "$1" == "--status" ]; then
    status
elif [ "$1" == "--help" ]; then
    echo "Docker 一键操作脚本用法:"
    echo "  ./docker-upgrade.sh           - 交互模式"
    echo "  ./docker-upgrade.sh --stop    - 仅停止容器"
    echo "  ./docker-upgrade.sh --upgrade - 仅升级镜像"
    echo "  ./docker-upgrade.sh --restart - 仅重启容器"
    echo "  ./docker-upgrade.sh --full    - 一键完整升级"
    echo "  ./docker-upgrade.sh --status  - 查看状态"
else
    main
fi
