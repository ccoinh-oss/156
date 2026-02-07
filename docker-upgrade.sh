#!/bin/bash

# =========================================================
# Docker & Compose 终极管理工具箱 (V4.0)
# =========================================================

set -e

# --- 颜色定义 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- 辅助函数 ---
log() { echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
pause() { echo -ne "\n${YELLOW}按回车键继续...${NC}"; read -r; }

# =========================================================
# 1. 镜像管理模块 (Image)
# =========================================================
menu_image() {
    clear
    echo -e "${PURPLE}=== [1] 镜像管理 (Images) ===${NC}"
    echo -e "1. 查看镜像列表    | # docker images          - 列出本地已下载的所有镜像"
    echo -e "2. 拉取远程镜像    | # docker pull [name]     - 从仓库下载最新版镜像"
    echo -e "3. 删除指定镜像    | # docker rmi [ID]        - 移除不再需要的本地镜像"
    echo -e "4. 搜索远程镜像    | # docker search [key]    - 在 Docker Hub 查找镜像"
    echo -e "5. 查看镜像详情    | # docker inspect [ID]    - 获取分层、元数据等底层信息"
    echo -e "6. 查看构建历史    | # docker history [ID]    - 显示镜像每一层的创建命令"
    echo -e "7. 导出为TAR包     | # docker save -o [f.tar] - 将镜像打包成文件以便离线传输"
    echo -e "8. 从TAR包导入     | # docker load -i [f.tar] - 将打包好的镜像文件加载到本地"
    echo -e "9. 清理虚悬镜像    | # docker image prune     - 删除那些标签为 <none> 的废弃镜像"
    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " img_opt
    case $img_opt in
        1) docker images; pause ;;
        2) read -p "请输入镜像名(如 nginx:latest): " name; docker pull "$name"; pause ;;
        3) read -p "请输入镜像ID或名称: " id; docker rmi "$id"; pause ;;
        4) read -p "请输入搜索关键词: " k; docker search "$k"; pause ;;
        5) read -p "请输入镜像ID: " id; docker inspect "$id"; pause ;;
        6) read -p "请输入镜像ID: " id; docker history "$id"; pause ;;
        7) read -p "镜像名: " id; read -p "保存文件名(如 myimg.tar): " f; docker save -o "$f" "$id"; pause ;;
        8) read -p "TAR包路径: " f; docker load -i "$f"; pause ;;
        9) docker image prune -f; log_success "清理完成"; pause ;;
        *) return ;;
    esac
    menu_image
}

# =========================================================
# 2. 容器管理模块 (Container)
# =========================================================
menu_container() {
    clear
    echo -e "${GREEN}=== [2] 容器管理 (Containers) ===${NC}"
    echo -e "1. 查看运行中容器  | # docker ps              - 只显示当前正在工作的容器"
    echo -e "2. 查看所有容器    | # docker ps -a           - 显示包括已停止在内的所有容器"
    echo -e "3. 启动容器        | # docker start [ID]      - 运行一个已存在的停止状态容器"
    echo -e "4. 停止容器        | # docker stop [ID]       - 正常关闭正在运行的容器"
    echo -e "5. 停止全部运行容器| # docker stop \$(docker ps) - 一键关闭宿主机上所有应用"
    echo -e "6. 重启容器        | # docker restart [ID]    - 重新启动容器(先关后开)"
    echo -e "7. 强制删除容器    | # docker rm -f [ID]      - 立即移除容器(即使正在运行)"
    echo -e "8. 进入容器内部    | # docker exec -it /bin/bash - 开启交互终端进行内部操作"
    echo -e "9. 查看容器日志    | # docker logs -f --tail  - 实时追踪容器运行时的输出"
    echo -e "10. 查看资源统计   | # docker stats           - 监控CPU、内存、网络IO占用"
    echo -e "11. 查看内部进程   | # docker top [ID]        - 显示容器内正在运行的进程列表"
    echo -e "12. 容器重命名     | # docker rename [old][new]- 修改已有容器的显示名称"
    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " con_opt
    case $con_opt in
        1) docker ps; pause ;;
        2) docker ps -a; pause ;;
        3) read -p "容器ID/名: " id; docker start "$id"; pause ;;
        4) read -p "容器ID/名: " id; docker stop "$id"; pause ;;
        5) ids=$(docker ps -q); [ -n "$ids" ] && docker stop $ids || echo "无运行中容器"; pause ;;
        6) read -p "容器ID/名: " id; docker restart "$id"; pause ;;
        7) read -p "容器ID/名: " id; docker rm -f "$id"; pause ;;
        8) read -p "容器ID/名: " id; docker exec -it "$id" /bin/bash || docker exec -it "$id" /bin/sh; pause ;;
        9) read -p "容器ID/名: " id; docker logs -f --tail=50 "$id"; pause ;;
        10) docker stats --no-stream; pause ;;
        11) read -p "容器ID/名: " id; docker top "$id"; pause ;;
        12) read -p "旧名: " old; read -p "新名: " new; docker rename "$old" "$new"; pause ;;
        *) return ;;
    esac
    menu_container
}

# =========================================================
# 3. Docker Compose 项目管理 (Upgrade/Dev)
# =========================================================
menu_compose() {
    clear
    echo -e "${YELLOW}=== [3] Compose 项目管理 (项目级操作) ===${NC}"
    echo -e "当前执行目录: ${CYAN}$(pwd)${NC}"
    echo "---------------------------------------------------"
    echo -e "1. 快速创建项目模板 | # mkdir & touch yml      - 新建目录并生成基础 yml 模板"
    echo -e "2. 启动并后台运行  | # docker compose up -d    - 根据配置启动整组容器服务"
    echo -e "3. 停止并移除项目  | # docker compose down     - 停止并销毁容器、网络、镜像"
    echo -e "4. 查看实时日志    | # docker compose logs -f  - 合并查看本项目内所有服务的日志"
    echo -e "5. 查看项目状态    | # docker compose ps       - 列出当前目录下管理的所有容器"
    echo -e "6. 重启项目服务    | # docker compose restart  - 重新启动项目内的所有容器"
    echo -e "7. 配置语法自检    | # docker compose config   - 验证 yml 文件配置是否正确"
    echo -e "8. ${RED}一键全自动化升级 | # pull && build && up   - 备份+拉取+重构+重启+清理${NC}"
    echo -e "   -> 解释: 适用于带 Dockerfile 的项目，会自动拉取最新镜像并重新编译本地源码。"
    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " cp_opt
    case $cp_opt in
        1)
            read -p "新项目目录名: " d; mkdir -p "$d"; cd "$d"
            echo "version: '3'" > docker-compose.yml
            echo "services: { web: { image: nginx:latest, ports: ['80:80'] } }" >> docker-compose.yml
            log_success "项目已创建在 $d"; pause ;;
        2) docker compose up -d; pause ;;
        3) docker compose down; pause ;;
        4) docker compose logs -f --tail=50; pause ;;
        5) docker compose ps; pause ;;
        6) docker compose restart; pause ;;
        7) docker compose config; pause ;;
        8) 
            if [ ! -f "docker-compose.yml" ]; then log_error "无 yml 文件"; pause; return; fi
            log "开始全自动维护流程..."
            log "STEP 1: 备份当前配置..." && cp docker-compose.yml "backup_$(date +%s).yml"
            log "STEP 2: 拉取远程镜像..." && docker compose pull
            log "STEP 3: 重新构建本地镜像(Build)..." && docker compose build
            log "STEP 4: 启动新版本容器..." && docker compose up -d --remove-orphans
            log "STEP 5: 清理过时镜像碎片..." && docker image prune -f
            log_success "一键升级已成功！"
            timeout 3s docker compose logs -f --tail=10 || true; pause ;;
        *) return ;;
    esac
    menu_compose
}

# =========================================================
# 4. 系统运维、网络与清理 (System)
# =========================================================
menu_system() {
    clear
    echo -e "${BLUE}=== [4] 系统运维与资源管理 ===${NC}"
    echo -e "1. 查看系统详情    | # docker info            - 显示宿主机配置、存储驱动等"
    echo -e "2. 安装 Docker 引擎 | # curl -fsSL get.docker  - 自动化在线安装官方 Docker"
    echo -e "3. 安装 Compose    | # apt install plugin     - 安装最新版 Docker Compose 插件"
    echo -e "4. 查看数据卷列表  | # docker volume ls       - 查看所有持久化存储卷"
    echo -e "5. 查看网络列表    | # docker network ls      - 查看桥接、主机、覆盖等网络"
    echo -e "6. 清理无用数据卷  | # docker volume prune    - 彻底删除没有被容器关联的卷"
    echo -e "7. 清理无用网络    | # docker network prune   - 移除所有未被使用的自定义网络"
    echo -e "8. ${RED}系统全面大扫除   | # docker system prune -a ${NC}- 删除所有停止容器、未用镜像/网络"
    echo -e "9. 重启服务进程    | # systemctl restart      - 遇到 Docker 抽风时强制重启后端进程"
    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " sys_opt
    case $sys_opt in
        1) docker info; pause ;;
        2) curl -fsSL https://get.docker.com | bash; pause ;;
        3) sudo apt install -y docker-compose-plugin || sudo yum install -y docker-compose-plugin; pause ;;
        4) docker volume ls; pause ;;
        5) docker network ls; pause ;;
        6) docker volume prune -f; pause ;;
        7) docker network prune -f; pause ;;
        8) log_warning "即将删除所有未运行的相关资源！"; docker system prune -a -f --volumes; pause ;;
        9) sudo systemctl restart docker; log_success "服务已重启"; pause ;;
        *) return ;;
    esac
    menu_system
}

# =========================================================
# 主程序
# =========================================================
main_menu() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           ${CYAN}Docker & Compose 终极全能大师 (V4.0)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${PURPLE}[1] 镜像管理 (Images)${NC}  - 镜像拉取、删除、导入导出及详情查询"
    echo -e "  ${GREEN}[2] 容器管理 (Containers)${NC}- 启动停止、实时监控、终端交互、日志查看"
    echo -e "  ${YELLOW}[3] 项目管理 (Compose)${NC}   - 自动化部署、一键升级、源码构建及重启"
    echo -e "  ${BLUE}[4] 系统运维 (System)${NC}    - 环境安装、卷与网络管理、深度大扫除"
    echo -e "--------------------------------------------------------------"
    echo -e "  ${RED}[q] 退出脚本 (Exit)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "请输入对应的分类编号 [1-4/q]: "
    read choice

    case $choice in
        1) menu_image ;;
        2) menu_container ;;
        3) menu_compose ;;
        4) menu_system ;;
        q|Q) exit 0 ;;
        *) echo "无效输入，请重新选择..." ; sleep 1 ;;
    esac
    main_menu
}

# 环境预检
if ! command -v docker &> /dev/null; then
    log_warning "警告: 未检测到 Docker，建议先执行 [4] 中的系统安装功能。"
fi

# 启动主界面
main_menu
