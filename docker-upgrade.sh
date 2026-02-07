#!/bin/bash

# =========================================================
# Docker & Compose 终极全能运维脚本 (V7.0 旗舰版)
# 特点：主菜单与子菜单全维度详解，命令字典级查询
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
pause() { echo -ne "\n${YELLOW}按回车键继续...${NC}"; read -r; }
header() { clear; echo -e "${CYAN}=== $1 ===${NC}"; }

# =========================================================
# 1. 镜像管理模块 (Images)
# =========================================================
menu_image() {
    header "镜像管理 (Images)"
    echo -e "1. ${GREEN}查看本地镜像${NC}   | # docker images         - ${GREEN}列出所有镜像${NC}"
    echo -e "   -> 解释: 查看本机已下载的所有镜像列表，包含 Tag、ID 和大小。"
    
    echo -e "2. ${GREEN}拉取远程镜像${NC}   | # docker pull [name]    - ${GREEN}下载镜像${NC}"
    echo -e "   -> 解释: 从 Docker Hub 下载最新版镜像 (如 mysql:8.0)。"
    
    echo -e "3. ${GREEN}搜索远程镜像${NC}   | # docker search [key]   - ${GREEN}查找镜像${NC}"
    echo -e "   -> 解释: 在官方仓库中搜索镜像，查看星级(Stars)和官方认证状态。"

    echo -e "4. ${YELLOW}查看镜像详情${NC}   | # docker inspect [ID]   - ${YELLOW}元数据分析${NC}"
    echo -e "   -> 解释: 查看镜像的底层信息，如环境变量(ENV)、暴露端口、启动命令。"

    echo -e "5. ${YELLOW}查看构建历史${NC}   | # docker history [ID]   - ${YELLOW}分层记录${NC}"
    echo -e "   -> 解释: 显示该镜像是如何一步步构建出来的，查看每一层的指令和大小。"

    echo -e "6. ${BLUE}导出镜像(离线)${NC} | # docker save -o [tar]  - ${BLUE}备份镜像${NC}"
    echo -e "   -> 解释: 将镜像打包成 .tar 文件，用于在无网服务器之间传输。"

    echo -e "7. ${BLUE}导入镜像(离线)${NC} | # docker load -i [tar]  - ${BLUE}恢复镜像${NC}"
    echo -e "   -> 解释: 从 .tar 文件中加载镜像到本地 Docker 环境。"

    echo -e "8. ${BLUE}镜像打标签${NC}     | # docker tag [ID] [new] - ${BLUE}重命名/别名${NC}"
    echo -e "   -> 解释: 给镜像起一个新名字（通常用于推送到私有仓库前）。"

    echo -e "9. ${BLUE}推送镜像${NC}       | # docker push [name]    - ${BLUE}上传仓库${NC}"
    echo -e "   -> 解释: 将本地制作好的镜像上传到 Docker Hub 或私有 Harbor。"

    echo -e "10. ${RED}删除指定镜像${NC}  | # docker rmi [ID]       - ${RED}常规删除${NC}"
    echo -e "   -> 解释: 删除不再使用的镜像。如果镜像正在被容器使用，会提示失败。"

    echo -e "11. ${RED}强制删除镜像${NC}  | # docker rmi -f [ID]    - ${RED}暴力删除${NC}"
    echo -e "   -> 解释: 即使有容器(停止状态)正在使用该镜像，也强制删除它。"

    echo -e "12. ${RED}清理虚悬镜像${NC}  | # docker image prune    - ${RED}垃圾回收${NC}"
    echo -e "   -> 解释: 一键删除所有名称为 <none> 的废弃中间层镜像，释放空间。"
    
    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " opt
    case $opt in
        1) docker images; pause ;;
        2) read -p "镜像名: " n; docker pull "$n"; pause ;;
        3) read -p "关键词: " n; docker search "$n"; pause ;;
        4) read -p "ID: " n; docker inspect "$n"; pause ;;
        5) read -p "ID: " n; docker history "$n"; pause ;;
        6) read -p "镜像ID: " i; read -p "保存为(xxx.tar): " f; docker save -o "$f" "$i"; pause ;;
        7) read -p "文件路径: " f; docker load -i "$f"; pause ;;
        8) read -p "源ID: " s; read -p "新名称: " t; docker tag "$s" "$t"; pause ;;
        9) read -p "镜像名: " n; docker push "$n"; pause ;;
        10) read -p "ID: " n; docker rmi "$n"; pause ;;
        11) read -p "ID: " n; docker rmi -f "$n"; pause ;;
        12) docker image prune -f; pause ;;
        *) return ;;
    esac
    menu_image
}

# =========================================================
# 2. 容器管理模块 (Containers)
# =========================================================
menu_container() {
    header "容器管理 (Containers)"
    echo -e "1. ${GREEN}查看运行容器${NC}   | # docker ps             - ${GREEN}仅显示在线${NC}"
    echo -e "   -> 解释: 查看当前正在运行的服务列表，包含端口映射和状态。"
    
    echo -e "2. ${GREEN}查看所有容器${NC}   | # docker ps -a          - ${GREEN}包含历史${NC}"
    echo -e "   -> 解释: 显示所有容器，包括已经停止(Exited)或崩溃的容器。"

    echo -e "3. ${GREEN}启动容器${NC}       | # docker start [ID]     - ${GREEN}开机${NC}"
    echo -e "   -> 解释: 启动一个之前停止过的容器。"

    echo -e "4. ${YELLOW}停止容器${NC}       | # docker stop [ID]      - ${YELLOW}关机(优雅)${NC}"
    echo -e "   -> 解释: 发送 SIGTERM 信号，让程序保存数据后安全退出。"

    echo -e "5. ${YELLOW}重启容器${NC}       | # docker restart [ID]   - ${YELLOW}重启${NC}"
    echo -e "   -> 解释: 等同于先 Stop 再 Start，常用于配置生效。"

    echo -e "6. ${RED}强制停止${NC}       | # docker kill [ID]      - ${RED}拔电源(暴力)${NC}"
    echo -e "   -> 解释: 发送 SIGKILL 信号，立即终止进程，可能导致数据丢失。"

    echo -e "7. ${BLUE}进入终端${NC}       | # docker exec -it bash  - ${BLUE}SSH式登录${NC}"
    echo -e "   -> 解释: 进入容器内部的命令行环境，进行文件修改或调试。"

    echo -e "8. ${BLUE}查看日志${NC}       | # docker logs -f        - ${BLUE}实时监控${NC}"
    echo -e "   -> 解释: 实时滚动显示应用程序的标准输出日志(stdout)。"

    echo -e "9. ${BLUE}文件拷贝${NC}       | # docker cp [src] [dst] - ${BLUE}传输文件${NC}"
    echo -e "   -> 解释: 在宿主机和容器之间双向拷贝文件 (如: 拷出配置文件)。"

    echo -e "10. ${BLUE}查看进程${NC}      | # docker top [ID]       - ${BLUE}内部进程${NC}"
    echo -e "   -> 解释: 查看容器内部运行了哪些 PID 进程。"

    echo -e "11. ${BLUE}查看变更${NC}      | # docker diff [ID]      - ${BLUE}文件变动${NC}"
    echo -e "   -> 解释: 查看容器内哪些文件被新增(A)、修改(C)或删除(D)。"

    echo -e "12. ${YELLOW}暂停/恢复${NC}     | # pause / unpause       - ${YELLOW}冻结进程${NC}"
    echo -e "   -> 解释: 暂时冻结容器的所有操作，不占用 CPU 但占用内存。"

    echo -e "13. ${RED}删除容器${NC}       | # docker rm [ID]        - ${RED}移除停止容器${NC}"
    echo -e "   -> 解释: 删除已经停止的容器，释放名称占用。"

    echo -e "14. ${RED}强制删除${NC}       | # docker rm -f [ID]     - ${RED}移除运行容器${NC}"
    echo -e "   -> 解释: 即使容器正在运行，也强制停止并删除它。"

    echo -e "15. ${RED}停止所有${NC}       | # stop \$(ps -q)        - ${RED}一键全停${NC}"
    echo -e "   -> 解释: 紧急操作，停止宿主机上所有正在运行的容器。"

    echo -e "16. ${YELLOW}容器重命名${NC}    | # docker rename         - ${YELLOW}改名${NC}"
    echo -e "   -> 解释: 修改容器的显示名称 (NAMES)。"

    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " opt
    case $opt in
        1) docker ps; pause ;;
        2) docker ps -a; pause ;;
        3) read -p "ID: " i; docker start "$i"; pause ;;
        4) read -p "ID: " i; docker stop "$i"; pause ;;
        5) read -p "ID: " i; docker restart "$i"; pause ;;
        6) read -p "ID: " i; docker kill "$i"; pause ;;
        7) read -p "ID: " i; docker exec -it "$i" /bin/bash || docker exec -it "$i" /bin/sh; pause ;;
        8) read -p "ID: " i; docker logs -f --tail=100 "$i"; pause ;;
        9) echo "用法: container:path hostpath"; read -p "输入CP参数: " a; docker cp $a; pause ;;
        10) read -p "ID: " i; docker top "$i"; pause ;;
        11) read -p "ID: " i; docker diff "$i"; pause ;;
        12) read -p "1=暂停 2=恢复: " t; read -p "ID: " i; [ "$t" == "1" ] && docker pause "$i" || docker unpause "$i"; pause ;;
        13) read -p "ID: " i; docker rm "$i"; pause ;;
        14) read -p "ID: " i; docker rm -f "$i"; pause ;;
        15) docker stop $(docker ps -q); pause ;;
        16) read -p "旧名: " o; read -p "新名: " n; docker rename "$o" "$n"; pause ;;
        *) return ;;
    esac
    menu_container
}

# =========================================================
# 3. Docker Compose 专项 (Project)
# =========================================================
menu_compose() {
    header "Compose 项目管理 (当前目录: $(basename $(pwd)))"
    
    echo -e "1. ${GREEN}后台启动${NC}       | # docker compose up -d  - ${GREEN}常规启动${NC}"
    echo -e "   -> 解释: 根据 docker-compose.yml 启动所有服务，并在后台运行。"

    echo -e "2. ${YELLOW}停止并清理${NC}     | # docker compose down   - ${YELLOW}彻底停止${NC}"
    echo -e "   -> 解释: 停止容器并移除容器、网络，但保留数据卷(Volume)。"

    echo -e "3. ${BLUE}查看项目日志${NC}   | # compose logs -f       - ${BLUE}聚合日志${NC}"
    echo -e "   -> 解释: 同时查看该项目下 web、db、redis 等所有服务的合并日志。"

    echo -e "4. ${BLUE}查看项目状态${NC}   | # docker compose ps     - ${BLUE}服务列表${NC}"
    echo -e "   -> 解释: 仅列出属于当前 Compose 项目的容器运行状态。"

    echo -e "5. ${YELLOW}重启项目${NC}       | # compose restart       - ${YELLOW}重启服务${NC}"
    echo -e "   -> 解释: 依次重启项目内的所有容器。"

    echo -e "6. ${BLUE}配置语法自检${NC}   | # compose config        - ${BLUE}语法检查${NC}"
    echo -e "   -> 解释: 检查 yml 文件是否有缩进错误或参数拼写错误。"

    echo -e "----------------- 核心升级区 -----------------"
    echo -e "7. ${GREEN}标准镜像升级${NC}   | # pull && up -d         - ${GREEN}拉取新镜像 -> 重启${NC}"
    echo -e "   -> 解释: 最常用。适用于 Nginx/MySQL 等直接使用官方镜像的项目，不涉及代码编译。"

    echo -e "8. ${RED}源码构建升级${NC}   | # pull && build && up   - ${RED}拉取 -> 编译 -> 重启${NC}"
    echo -e "   -> 解释: 适用于带 Dockerfile 的项目，会自动重编译本地代码。"

    echo -e "9. ${YELLOW}强制重建容器${NC}   | # up -d --force-recreate- ${YELLOW}不升级镜像，仅重建${NC}"
    echo -e "   -> 解释: 镜像没变但配置没生效时，强制删除旧容器并重新创建。"

    echo -e "10. ${BLUE}配置热加载${NC}     | # up -d                 - ${BLUE}仅应用配置变更${NC}"
    echo -e "   -> 解释: 修改了 docker-compose.yml 端口或环境变量后，使用此项生效。"
    
    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " opt
    case $opt in
        1) docker compose up -d; pause ;;
        2) docker compose down; pause ;;
        3) docker compose logs -f --tail=50; pause ;;
        4) docker compose ps; pause ;;
        5) docker compose restart; pause ;;
        6) docker compose config; pause ;;
        7) 
            echo -e "\n${CYAN}>>> 执行标准升级...${NC}"
            docker compose pull && docker compose up -d --remove-orphans && docker image prune -f
            pause ;;
        8) 
            echo -e "\n${CYAN}>>> 执行构建升级...${NC}"
            docker compose pull && docker compose build && docker compose up -d --remove-orphans && docker image prune -f
            pause ;;
        9) docker compose up -d --force-recreate; pause ;;
        10) docker compose up -d; pause ;;
        *) return ;;
    esac
    menu_compose
}

# =========================================================
# 4. 系统/网络/数据卷 (System)
# =========================================================
menu_system() {
    header "系统/网络/数据卷"
    echo -e "1. ${BLUE}系统详情${NC}       | # docker info           - ${BLUE}调试信息${NC}"
    echo -e "   -> 解释: 查看内核版本、容器数量、镜像仓库地址、存储驱动等。"

    echo -e "2. ${BLUE}磁盘占用${NC}       | # docker system df      - ${BLUE}空间分析${NC}"
    echo -e "   -> 解释: 查看镜像、容器、数据卷分别占用了多少磁盘空间。"

    echo -e "3. ${GREEN}登录仓库${NC}       | # docker login          - ${GREEN}身份认证${NC}"
    echo -e "   -> 解释: 登录 Docker Hub 或私有仓库，以便推送/拉取私有镜像。"

    echo -e "4. ${BLUE}查看网络${NC}       | # docker network ls     - ${BLUE}网络列表${NC}"
    echo -e "   -> 解释: 查看 Bridge、Host、None 等网络模式。"

    echo -e "5. ${BLUE}查看数据卷${NC}     | # docker volume ls      - ${BLUE}卷列表${NC}"
    echo -e "   -> 解释: 查看所有的持久化数据卷 (Volumes)。"

    echo -e "6. ${BLUE}网络详情${NC}       | # network inspect [ID]  - ${BLUE}IP分配${NC}"
    echo -e "   -> 解释: 查看指定网络下连接了哪些容器，以及它们的 IP 地址。"

    echo -e "7. ${BLUE}数据卷详情${NC}     | # volume inspect [ID]   - ${BLUE}宿主机路径${NC}"
    echo -e "   -> 解释: 查看数据卷在宿主机上的具体存放目录位置。"

    echo -e "8. ${RED}清理无用网络${NC}   | # network prune         - ${RED}删除空网络${NC}"
    echo -e "   -> 解释: 删除那些没有被任何容器使用的自定义网络。"

    echo -e "9. ${RED}清理无用卷${NC}     | # volume prune          - ${RED}删除空卷(慎用)${NC}"
    echo -e "   -> 解释: 删除没有挂载到容器的数据卷，注意数据会丢失！"

    echo -e "10. ${RED}系统大扫除${NC}    | # system prune -a       - ${RED}深度清理${NC}"
    echo -e "   -> 解释: 删除所有停止的容器、未使用的网络、未被使用的镜像。"

    echo -e "11. ${RED}重启Docker${NC}    | # systemctl restart     - ${RED}重启服务${NC}"
    echo -e "   -> 解释: 重启 Docker 守护进程 (Daemon)。"
    
    echo -e "12. ${GREEN}安装Docker${NC}    | # curl | bash           - ${GREEN}一键安装${NC}"
    echo -e "   -> 解释: 调用官方脚本自动安装 Docker 及 Compose 插件。"

    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " opt
    case $opt in
        1) docker info; pause ;;
        2) docker system df; pause ;;
        3) docker login; pause ;;
        4) docker network ls; pause ;;
        5) docker volume ls; pause ;;
        6) read -p "网络ID: " n; docker network inspect "$n"; pause ;;
        7) read -p "卷名: " n; docker volume inspect "$n"; pause ;;
        8) docker network prune -f; pause ;;
        9) docker volume prune -f; pause ;;
        10) docker system prune -a -f --volumes; pause ;;
        11) sudo systemctl restart docker; pause ;;
        12) curl -fsSL https://get.docker.com | bash; pause ;;
        *) return ;;
    esac
    menu_system
}

# =========================================================
# 主入口
# =========================================================
main_menu() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           ${CYAN}Docker 终极全能运维脚本 (V7.0 旗舰版)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e "  ${PURPLE}[1] 镜像管理 (Images)${NC}"
    echo -e "     • 核心功能: 拉取(Pull)、搜索(Search)、推送(Push)、清理(Prune)"
    echo -e "     • 进阶操作: 离线导入导出(Save/Load)、历史查看(History)、打标签"

    echo -e "  ${GREEN}[2] 容器管理 (Containers)${NC}"
    echo -e "     • 生命周期: 启动(Start)、停止(Stop)、重启(Restart)、强制Kill"
    echo -e "     • 运维调试: 实时日志(Logs)、进入终端(Exec)、文件拷贝(CP)、资源监控"

    echo -e "  ${YELLOW}[3] 项目管理 (Compose)${NC}"
    echo -e "     • 核心升级: ${GREEN}标准升级(Pull+Up)${NC} | ${RED}构建升级(Build+Up)${NC}"
    echo -e "     • 项目运维: 配置热加载、日志聚合、一键重启、状态监控"

    echo -e "  ${BLUE}[4] 系统运维 (System)${NC}"
    echo -e "     • 资源管理: 磁盘分析(DF)、网络(Net)、数据卷(Vol)管理"
    echo -e "     • 环境维护: 深度大扫除(Prune -a)、服务重启、一键安装"

    echo -e "--------------------------------------------------------------"
    echo -e "  ${RED}[q] 退出脚本 (Exit)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "请输入功能区编号: "
    read choice

    case $choice in
        1) menu_image ;;
        2) menu_container ;;
        3) menu_compose ;;
        4) menu_system ;;
        q|Q) exit 0 ;;
        *) echo "无效选择" ; sleep 1 ;;
    esac
    main_menu
}

# 检查环境
if ! command -v docker &> /dev/null; then
    echo -e "${RED}未检测到 Docker，建议选择 [4] -> [12] 进行安装。${NC}"
    sleep 2
fi

main_menu
