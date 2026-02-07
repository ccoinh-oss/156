#!/bin/bash

# =========================================================
# Docker & Compose 终极全能运维脚本 (V9.0 终极完整版)
# 特点：6大模块 - 镜像/容器/Compose/系统网络/构建/安全诊断
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
    echo -e "1. ${GREEN}查看本地镜像${NC}   | # docker images         - 列出所有镜像 (Tag/ID/Size)"
    echo -e "2. ${GREEN}拉取远程镜像${NC}   | # docker pull [name]    - 下载镜像 (如 mysql:8.0)"
    echo -e "3. ${GREEN}搜索远程镜像${NC}   | # docker search [key]   - 在 Hub 中查找镜像"
    echo -e "4. ${YELLOW}查看镜像详情${NC}   | # docker inspect [ID]   - 元数据分析 (ENV/CMD/Layers)"
    echo -e "5. ${YELLOW}查看构建历史${NC}   | # docker history [ID]   - 查看分层构建记录"
    echo -e "6. ${BLUE}导出镜像(离线)${NC} | # docker save -o [tar]  - 备份镜像为 .tar 文件"
    echo -e "7. ${BLUE}导入镜像(离线)${NC} | # docker load -i [tar]  - 从 .tar 文件恢复镜像"
    echo -e "8. ${BLUE}镜像打标签${NC}     | # docker tag [ID] [new] - 重命名/创建别名"
    echo -e "9. ${BLUE}推送镜像${NC}       | # docker push [name]    - 上传到仓库 (Hub/Harbor)"
    echo -e "10. ${RED}删除指定镜像${NC}  | # docker rmi [ID]       - 删除不再使用的镜像"
    echo -e "11. ${RED}强制删除镜像${NC}  | # docker rmi -f [ID]    - 强制删除 (即使被引用)"
    echo -e "12. ${RED}清理虚悬镜像${NC}  | # docker image prune    - 删除所有 <none> 镜像"
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
    echo -e "1. ${GREEN}查看运行容器${NC}   | # docker ps             - 仅显示在线容器"
    echo -e "2. ${GREEN}查看所有容器${NC}   | # docker ps -a          - 包含已停止的历史容器"
    echo -e "3. ${GREEN}启动容器${NC}       | # docker start [ID]     - 启动已停止的容器"
    echo -e "4. ${YELLOW}停止容器${NC}       | # docker stop [ID]      - 优雅关机 (SIGTERM)"
    echo -e "5. ${YELLOW}重启容器${NC}       | # docker restart [ID]   - 重启 (Stop + Start)"
    echo -e "6. ${RED}强制停止${NC}       | # docker kill [ID]      - 暴力关机 (SIGKILL)"
    echo -e "7. ${BLUE}进入终端${NC}       | # docker exec -it bash  - 进入容器内部命令行"
    echo -e "8. ${BLUE}查看日志${NC}       | # docker logs -f        - 实时监控控制台输出"
    echo -e "9. ${BLUE}文件拷贝${NC}       | # docker cp [src] [dst] - 宿主机/容器文件互传"
    echo -e "10. ${BLUE}查看进程${NC}      | # docker top [ID]       - 查看内部 PID 进程"
    echo -e "11. ${BLUE}查看变更${NC}      | # docker diff [ID]      - 查看文件系统变动"
    echo -e "12. ${YELLOW}暂停/恢复${NC}     | # pause / unpause       - 冻结/解冻容器进程"
    echo -e "13. ${RED}删除容器${NC}       | # docker rm [ID]        - 删除已停止的容器"
    echo -e "14. ${RED}强制删除${NC}       | # docker rm -f [ID]     - 强制删除运行中的容器"
    echo -e "15. ${RED}停止所有${NC}       | # stop \$(ps -q)        - 一键停止所有容器"
    echo -e "16. ${YELLOW}容器重命名${NC}    | # docker rename         - 修改容器名称"
    echo -e "17. ${BLUE}资源监控${NC}      | # docker stats          - 实时CPU/内存/网络/IO监控"
    echo -e "18. ${BLUE}容器详情${NC}      | # docker inspect [ID]   - 查看容器完整元数据"
    echo -e "19. ${BLUE}导出容器${NC}      | # docker export [ID]    - 将容器文件系统导出为tar"
    echo -e "20. ${BLUE}导入容器${NC}      | # docker import [tar]   - 从tar创建新镜像"
    echo -e "21. ${PURPLE}提交为镜像${NC}    | # docker commit [ID]    - 将运行中容器保存为新镜像"
    echo -e "22. ${BLUE}查看端口映射${NC}  | # docker port [ID]      - 查看容器端口映射关系"
    echo -e "23. ${YELLOW}等待容器退出${NC}  | # docker wait [ID]      - 阻塞等待容器停止返回退出码"
    echo -e "24. ${YELLOW}更新资源限制${NC}  | # docker update [ID]    - 动态修改CPU/内存限制"
    echo -e "25. ${RED}清理已停止容器${NC}| # container prune       - 批量删除所有已停止容器"
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
        9) echo "格式: container:path hostpath"; read -p "输入CP参数: " a; docker cp $a; pause ;;
        10) read -p "ID: " i; docker top "$i"; pause ;;
        11) read -p "ID: " i; docker diff "$i"; pause ;;
        12) read -p "1=暂停 2=恢复: " t; read -p "ID: " i; [ "$t" == "1" ] && docker pause "$i" || docker unpause "$i"; pause ;;
        13) read -p "ID: " i; docker rm "$i"; pause ;;
        14) read -p "ID: " i; docker rm -f "$i"; pause ;;
        15) docker stop $(docker ps -q); pause ;;
        16) read -p "旧名: " o; read -p "新名: " n; docker rename "$o" "$n"; pause ;;
        17) docker stats; pause ;;
        18) read -p "ID: " i; docker inspect "$i"; pause ;;
        19) read -p "ID: " i; read -p "保存为(xxx.tar): " f; docker export -o "$f" "$i"; pause ;;
        20) read -p "文件路径: " f; read -p "新镜像名: " n; docker import "$f" "$n"; pause ;;
        21) read -p "容器ID: " i; read -p "新镜像名(如 myimg:v1): " n; docker commit "$i" "$n"; pause ;;
        22) read -p "ID: " i; docker port "$i"; pause ;;
        23) read -p "ID: " i; echo "等待容器退出..."; docker wait "$i"; pause ;;
        24) read -p "ID: " i; echo "示例: --memory 512m --cpus 1.5"; read -p "参数: " p; docker update $p "$i"; pause ;;
        25) docker container prune -f; pause ;;
        *) return ;;
    esac
    menu_container
}

# =========================================================
# 3. Docker Compose 专项 (Project) - 20项全功能
# =========================================================
menu_compose() {
    header "Compose 项目管理 (当前目录: $(basename $(pwd)))"
    
    echo -e "${CYAN}--- [构建与销毁 (Lifecycle)] ---${NC}"
    echo -e "1. ${GREEN}构建并启动${NC}     | # up -d                 - ${GREEN}最常用${NC}: 创建容器、网络并启动"
    echo -e "2. ${YELLOW}停止并移除${NC}     | # down                  - ${YELLOW}销毁${NC}: 停止并删除容器、网络"
    echo -e "3. ${RED}停止移除(含卷)${NC} | # down -v               - ${RED}彻底销毁${NC}: 连同数据卷(Volume)一起删"

    echo -e "${CYAN}--- [状态控制 (State)] ---${NC}"
    echo -e "4. ${GREEN}启动服务${NC}       | # start                 - 仅启动已存在的停止容器 (不新建)"
    echo -e "5. ${YELLOW}停止服务${NC}       | # stop                  - 仅停止运行，保留容器和数据"
    echo -e "6. ${YELLOW}重启服务${NC}       | # restart               - 依次重启所有容器"
    echo -e "7. ${BLUE}暂停进程${NC}       | # pause                 - 暂停服务运行 (冻结状态)"
    echo -e "8. ${BLUE}恢复进程${NC}       | # unpause               - 恢复暂停的服务"
    echo -e "9. ${RED}强制杀死${NC}       | # kill                  - 强制发送 SIGKILL 信号"

    echo -e "${CYAN}--- [信息与监控 (Info)] ---${NC}"
    echo -e "10. ${BLUE}查看日志${NC}      | # logs -f               - 聚合查看所有服务的日志"
    echo -e "11. ${BLUE}查看进程${NC}      | # top                   - 查看各容器内的进程详情"
    echo -e "12. ${BLUE}服务状态${NC}      | # ps                    - 列出项目内所有容器状态"
    echo -e "13. ${BLUE}项目镜像${NC}      | # images                - 列出当前项目使用的所有镜像"
    echo -e "14. ${BLUE}查看事件${NC}      | # events                - 实时监控项目的操作事件"

    echo -e "${CYAN}--- [高级操作 (Advanced)] ---${NC}"
    echo -e "15. ${PURPLE}进入服务${NC}      | # exec [svc] bash       - 进入指定服务的命令行"
    echo -e "16. ${PURPLE}配置检查${NC}      | # config                - 验证 yml 文件语法"
    
    echo -e "${CYAN}--- [升级与维护 (Upgrade)] ---${NC}"
    echo -e "17. ${GREEN}标准镜像升级${NC}   | # pull && up -d         - 拉取最新镜像 -> 重启"
    echo -e "18. ${RED}源码构建升级${NC}   | # pull && build && up   - 拉取 -> 重新编译 -> 重启"
    echo -e "19. ${YELLOW}强制重建容器${NC}   | # up -d --force-recreate- 不升级镜像，仅强制重置容器"
    echo -e "20. ${BLUE}配置热加载${NC}     | # up -d                 - 仅应用配置变更 (端口/环境变量)"

    echo -e "${CYAN}--- [扩展操作 (Extended)] ---${NC}"
    echo -e "21. ${BLUE}单服务日志${NC}     | # logs [svc]            - 只查看指定服务的日志"
    echo -e "22. ${PURPLE}服务扩缩容${NC}     | # up --scale [svc]=N    - 动态调整服务副本数量"
    echo -e "23. ${PURPLE}运行临时命令${NC}   | # run [svc] [cmd]       - 在服务中运行一次性命令"
    echo -e "24. ${YELLOW}单服务构建${NC}     | # build [svc]           - 只构建指定服务的镜像"
    echo -e "25. ${YELLOW}拉取指定服务${NC}   | # pull [svc]            - 只拉取指定服务的镜像"
    echo -e "26. ${BLUE}Compose版本${NC}    | # version               - 查看 Docker Compose 版本"
    echo -e "27. ${PURPLE}指定yml操作${NC}    | # -f [file] up -d       - 使用指定的 yml 文件启动"

    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " opt
    case $opt in
        1) docker compose up -d; pause ;;
        2) docker compose down; pause ;;
        3) docker compose down -v; pause ;;
        4) docker compose start; pause ;;
        5) docker compose stop; pause ;;
        6) docker compose restart; pause ;;
        7) docker compose pause; pause ;;
        8) docker compose unpause; pause ;;
        9) docker compose kill; pause ;;
        10) docker compose logs -f --tail=50; pause ;;
        11) docker compose top; pause ;;
        12) docker compose ps; pause ;;
        13) docker compose images; pause ;;
        14) echo "按 Ctrl+C 退出监控"; docker compose events; pause ;;
        15) read -p "输入服务名(如 web): " s; docker compose exec -it "$s" /bin/bash || docker compose exec -it "$s" /bin/sh; pause ;;
        16) docker compose config; pause ;;
        17) 
            echo -e "\n${CYAN}>>> 执行标准升级...${NC}"
            docker compose pull && docker compose up -d --remove-orphans && docker image prune -f
            pause ;;
        18) 
            echo -e "\n${CYAN}>>> 执行构建升级...${NC}"
            docker compose pull && docker compose build && docker compose up -d --remove-orphans && docker image prune -f
            pause ;;
        19) docker compose up -d --force-recreate; pause ;;
        20) docker compose up -d; pause ;;
        21) read -p "服务名: " s; docker compose logs -f --tail=50 "$s"; pause ;;
        22) read -p "服务名: " s; read -p "副本数: " n; docker compose up -d --scale "$s=$n"; pause ;;
        23) read -p "服务名: " s; read -p "命令: " c; docker compose run --rm "$s" $c; pause ;;
        24) read -p "服务名: " s; docker compose build "$s"; pause ;;
        25) read -p "服务名: " s; docker compose pull "$s"; pause ;;
        26) docker compose version; pause ;;
        27) read -p "yml文件路径: " f; read -p "操作(如 up -d): " c; docker compose -f "$f" $c; pause ;;
        *) return ;;
    esac
    menu_compose
}

# =========================================================
# 4. 系统/网络/数据卷 (System)
# =========================================================
menu_system() {
    header "系统/网络/数据卷"
    echo -e "1. ${BLUE}系统详情${NC}       | # docker info           - 查看内核、存储、容器数"
    echo -e "2. ${BLUE}磁盘占用${NC}       | # docker system df      - 分析镜像/容器/卷的占用"
    echo -e "3. ${GREEN}登录仓库${NC}       | # docker login          - 登录 Hub 或私有库"
    echo -e "4. ${BLUE}查看网络${NC}       | # docker network ls     - 列出所有网络模式"
    echo -e "5. ${BLUE}查看数据卷${NC}     | # docker volume ls      - 列出持久化卷"
    echo -e "6. ${BLUE}网络详情${NC}       | # network inspect [ID]  - 查看网络IP分配情况"
    echo -e "7. ${BLUE}数据卷详情${NC}     | # volume inspect [ID]   - 查看卷的物理路径"
    echo -e "8. ${RED}清理无用网络${NC}   | # network prune         - 删除未使用的网络"
    echo -e "9. ${RED}清理无用卷${NC}     | # volume prune          - 删除未挂载的卷 (慎用!)"
    echo -e "10. ${RED}系统大扫除${NC}    | # system prune -a       - 深度清理 (容器/镜像/网络)"
    echo -e "11. ${RED}重启Docker${NC}    | # systemctl restart     - 重启 Docker 服务进程"
    echo -e "12. ${GREEN}安装Docker${NC}    | # curl | bash           - 官方脚本一键安装"

    echo -e "${CYAN}--- [网络高级操作] ---${NC}"
    echo -e "13. ${GREEN}创建网络${NC}      | # network create        - 创建自定义网络"
    echo -e "14. ${RED}删除网络${NC}      | # network rm            - 删除指定网络"
    echo -e "15. ${BLUE}容器加入网络${NC}  | # network connect       - 将容器连接到网络"
    echo -e "16. ${BLUE}容器离开网络${NC}  | # network disconnect    - 将容器从网络断开"

    echo -e "${CYAN}--- [数据卷高级操作] ---${NC}"
    echo -e "17. ${GREEN}创建数据卷${NC}    | # volume create         - 创建命名数据卷"
    echo -e "18. ${RED}删除数据卷${NC}    | # volume rm             - 删除指定数据卷"

    echo -e "${CYAN}--- [服务诊断] ---${NC}"
    echo -e "19. ${BLUE}Docker版本${NC}    | # docker version        - 查看客户端/服务端版本"
    echo -e "20. ${BLUE}Docker事件${NC}    | # docker events         - 实时监控守护进程事件"
    echo -e "21. ${YELLOW}配置镜像加速${NC}  | # daemon.json           - 配置国内镜像源加速"
    echo -e "22. ${BLUE}Docker服务日志${NC}| # journalctl -u docker  - 查看Docker服务日志"

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
        13) read -p "网络名: " n; read -p "驱动(bridge/overlay,默认bridge): " d; docker network create --driver "${d:-bridge}" "$n"; pause ;;
        14) read -p "网络名: " n; docker network rm "$n"; pause ;;
        15) read -p "网络名: " n; read -p "容器ID: " i; docker network connect "$n" "$i"; pause ;;
        16) read -p "网络名: " n; read -p "容器ID: " i; docker network disconnect "$n" "$i"; pause ;;
        17) read -p "卷名: " n; docker volume create "$n"; pause ;;
        18) read -p "卷名: " n; docker volume rm "$n"; pause ;;
        19) docker version; pause ;;
        20) echo "按 Ctrl+C 退出监控"; docker events; pause ;;
        21)
            echo -e "${CYAN}>>> 配置镜像加速源${NC}"
            echo "常用加速源:"
            echo "  阿里云: https://xxxxx.mirror.aliyuncs.com (需登录获取)"
            echo "  腾讯云: https://mirror.ccs.tencentyun.com"
            echo "  华为云: https://05f073ad3c0010ea0f4bc00b7105ec20.mirror.swr.myhuaweicloud.com"
            read -p "输入加速地址: " mirror
            sudo mkdir -p /etc/docker
            echo "{\"registry-mirrors\": [\"$mirror\"]}" | sudo tee /etc/docker/daemon.json
            sudo systemctl daemon-reload && sudo systemctl restart docker
            echo -e "${GREEN}镜像加速配置完成!${NC}"
            pause ;;
        22) sudo journalctl -u docker --no-pager --lines=100; pause ;;
        *) return ;;
    esac
    menu_system
}

# =========================================================
# 5. Dockerfile 构建模块 (Build)
# =========================================================
menu_build() {
    header "Dockerfile 构建 (Build)"
    echo -e "1. ${GREEN}标准构建${NC}       | # docker build .        - 从当前目录Dockerfile构建"
    echo -e "2. ${GREEN}指定文件构建${NC}   | # build -f [file]       - 指定Dockerfile路径构建"
    echo -e "3. ${YELLOW}无缓存构建${NC}     | # build --no-cache      - 忽略缓存完全重新构建"
    echo -e "4. ${BLUE}多阶段构建${NC}     | # build --target [stg]  - 只构建到指定阶段"
    echo -e "5. ${BLUE}构建并打标签${NC}   | # build -t [name:tag]   - 构建并直接命名镜像"
    echo -e "6. ${PURPLE}构建传参${NC}       | # build --build-arg     - 传递构建时变量"
    echo -e "7. ${BLUE}查看构建缓存${NC}   | # builder du            - 查看构建缓存占用"
    echo -e "8. ${RED}清理构建缓存${NC}   | # builder prune         - 清理所有构建缓存"
    echo -e "9. ${BLUE}多平台构建${NC}     | # buildx build          - 构建多架构镜像(amd64/arm64)"
    echo -e "10. ${BLUE}查看buildx${NC}   | # buildx ls             - 查看构建器实例列表"
    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " opt
    case $opt in
        1) read -p "镜像名(如 myapp:latest): " n; docker build -t "$n" .; pause ;;
        2) read -p "Dockerfile路径: " f; read -p "镜像名: " n; docker build -f "$f" -t "$n" .; pause ;;
        3) read -p "镜像名: " n; docker build --no-cache -t "$n" .; pause ;;
        4) read -p "阶段名(target): " s; read -p "镜像名: " n; docker build --target "$s" -t "$n" .; pause ;;
        5) read -p "镜像名(name:tag): " n; docker build -t "$n" .; pause ;;
        6) read -p "镜像名: " n; read -p "参数(如 VERSION=1.0): " a; docker build --build-arg "$a" -t "$n" .; pause ;;
        7) docker builder du; pause ;;
        8) docker builder prune -f; pause ;;
        9) read -p "镜像名: " n; read -p "平台(如 linux/amd64,linux/arm64): " p; docker buildx build --platform "$p" -t "$n" .; pause ;;
        10) docker buildx ls; pause ;;
        *) return ;;
    esac
    menu_build
}

# =========================================================
# 6. 安全与诊断模块 (Security & Diagnostics)
# =========================================================
menu_security() {
    header "安全与诊断 (Security & Diagnostics)"

    echo -e "${CYAN}--- [健康与状态] ---${NC}"
    echo -e "1. ${GREEN}容器健康状态${NC}   | # ps --filter health    - 查看容器健康检查结果"
    echo -e "2. ${BLUE}容器资源限制${NC}   | # inspect (Resources)   - 查看容器CPU/内存限制"
    echo -e "3. ${BLUE}容器启动命令${NC}   | # inspect (Config)      - 查看容器启动命令和环境变量"

    echo -e "${CYAN}--- [安全检查] ---${NC}"
    echo -e "4. ${YELLOW}特权容器检查${NC}   | # inspect (Privileged)  - 检查是否有特权模式容器"
    echo -e "5. ${YELLOW}Root用户检查${NC}   | # inspect (User)        - 检查容器是否以root运行"
    echo -e "6. ${BLUE}只读文件系统${NC}   | # inspect (ReadOnly)    - 检查容器文件系统是否只读"
    echo -e "7. ${BLUE}挂载卷检查${NC}     | # inspect (Mounts)      - 查看容器所有挂载点"

    echo -e "${CYAN}--- [Docker配置] ---${NC}"
    echo -e "8. ${BLUE}Daemon配置${NC}     | # cat daemon.json       - 查看Docker守护进程配置"
    echo -e "9. ${BLUE}存储驱动${NC}       | # info (Storage)        - 查看存储驱动和数据目录"
    echo -e "10. ${YELLOW}Docker安全基线${NC}| # 综合检查              - 一键安全基线扫描"

    echo -e "${CYAN}--- [日志与调试] ---${NC}"
    echo -e "11. ${BLUE}容器日志大小${NC}  | # 检查日志文件大小      - 查找占用磁盘的大日志"
    echo -e "12. ${RED}清理容器日志${NC}  | # truncate log          - 清空指定容器的日志文件"

    echo -e "0. 返回主菜单"
    echo "---------------------------------------------------"
    read -p "选择操作: " opt
    case $opt in
        1) docker ps -a --format "table {{.Names}}\t{{.Status}}" | head -30; pause ;;
        2) read -p "容器ID: " i; docker inspect "$i" --format '{{.HostConfig.Memory}} bytes Memory | {{.HostConfig.NanoCpus}} NanoCPUs'; pause ;;
        3) read -p "容器ID: " i; docker inspect "$i" --format 'CMD: {{.Config.Cmd}} | Entrypoint: {{.Config.Entrypoint}}'; echo "--- 环境变量 ---"; docker inspect "$i" --format '{{range .Config.Env}}{{println .}}{{end}}'; pause ;;
        4)
            echo -e "${CYAN}>>> 检查特权容器...${NC}"
            for c in $(docker ps -q); do
                name=$(docker inspect --format '{{.Name}}' "$c")
                priv=$(docker inspect --format '{{.HostConfig.Privileged}}' "$c")
                [ "$priv" == "true" ] && echo -e "${RED}[危险] $name 运行在特权模式!${NC}" || echo -e "${GREEN}[安全] $name 非特权模式${NC}"
            done
            pause ;;
        5)
            echo -e "${CYAN}>>> 检查Root用户容器...${NC}"
            for c in $(docker ps -q); do
                name=$(docker inspect --format '{{.Name}}' "$c")
                user=$(docker inspect --format '{{.Config.User}}' "$c")
                [ -z "$user" ] && echo -e "${YELLOW}[警告] $name 以root运行 (未指定User)${NC}" || echo -e "${GREEN}[安全] $name 用户: $user${NC}"
            done
            pause ;;
        6)
            echo -e "${CYAN}>>> 检查只读文件系统...${NC}"
            for c in $(docker ps -q); do
                name=$(docker inspect --format '{{.Name}}' "$c")
                ro=$(docker inspect --format '{{.HostConfig.ReadonlyRootfs}}' "$c")
                [ "$ro" == "true" ] && echo -e "${GREEN}[安全] $name 只读文件系统${NC}" || echo -e "${YELLOW}[提示] $name 可写文件系统${NC}"
            done
            pause ;;
        7) read -p "容器ID: " i; docker inspect "$i" --format '{{range .Mounts}}Type:{{.Type}} Src:{{.Source}} Dst:{{.Destination}} RW:{{.RW}}{{println}}{{end}}'; pause ;;
        8)
            if [ -f /etc/docker/daemon.json ]; then
                cat /etc/docker/daemon.json
            else
                echo -e "${YELLOW}daemon.json 不存在 (使用默认配置)${NC}"
            fi
            pause ;;
        9) docker info --format 'Storage Driver: {{.Driver}}
Docker Root Dir: {{.DockerRootDir}}
Containers: {{.Containers}} (Running: {{.ContainersRunning}})
Images: {{.Images}}'; pause ;;
        10)
            echo -e "${CYAN}━━━ Docker 安全基线扫描 ━━━${NC}"
            echo ""
            echo -e "${CYAN}[1/5] 特权容器检查${NC}"
            for c in $(docker ps -q); do
                name=$(docker inspect --format '{{.Name}}' "$c")
                priv=$(docker inspect --format '{{.HostConfig.Privileged}}' "$c")
                [ "$priv" == "true" ] && echo -e "  ${RED}[FAIL] $name 特权模式${NC}" || echo -e "  ${GREEN}[PASS] $name${NC}"
            done
            echo ""
            echo -e "${CYAN}[2/5] Root用户检查${NC}"
            for c in $(docker ps -q); do
                name=$(docker inspect --format '{{.Name}}' "$c")
                user=$(docker inspect --format '{{.Config.User}}' "$c")
                [ -z "$user" ] && echo -e "  ${YELLOW}[WARN] $name root运行${NC}" || echo -e "  ${GREEN}[PASS] $name${NC}"
            done
            echo ""
            echo -e "${CYAN}[3/5] 网络模式检查${NC}"
            for c in $(docker ps -q); do
                name=$(docker inspect --format '{{.Name}}' "$c")
                net=$(docker inspect --format '{{.HostConfig.NetworkMode}}' "$c")
                [ "$net" == "host" ] && echo -e "  ${YELLOW}[WARN] $name 使用host网络${NC}" || echo -e "  ${GREEN}[PASS] $name ($net)${NC}"
            done
            echo ""
            echo -e "${CYAN}[4/5] PID模式检查${NC}"
            for c in $(docker ps -q); do
                name=$(docker inspect --format '{{.Name}}' "$c")
                pid=$(docker inspect --format '{{.HostConfig.PidMode}}' "$c")
                [ "$pid" == "host" ] && echo -e "  ${RED}[FAIL] $name 共享宿主PID${NC}" || echo -e "  ${GREEN}[PASS] $name${NC}"
            done
            echo ""
            echo -e "${CYAN}[5/5] 资源限制检查${NC}"
            for c in $(docker ps -q); do
                name=$(docker inspect --format '{{.Name}}' "$c")
                mem=$(docker inspect --format '{{.HostConfig.Memory}}' "$c")
                [ "$mem" == "0" ] && echo -e "  ${YELLOW}[WARN] $name 无内存限制${NC}" || echo -e "  ${GREEN}[PASS] $name (${mem}B)${NC}"
            done
            echo ""
            echo -e "${CYAN}━━━ 扫描完成 ━━━${NC}"
            pause ;;
        11)
            echo -e "${CYAN}>>> 容器日志文件大小 (Top 20)${NC}"
            sudo find /var/lib/docker/containers/ -name "*.log" -exec ls -lh {} \; 2>/dev/null | sort -k5 -h -r | head -20
            pause ;;
        12)
            read -p "容器ID: " i
            log_path=$(docker inspect --format='{{.LogPath}}' "$i")
            if [ -n "$log_path" ]; then
                sudo truncate -s 0 "$log_path"
                echo -e "${GREEN}已清空日志: $log_path${NC}"
            else
                echo -e "${RED}未找到日志路径${NC}"
            fi
            pause ;;
        *) return ;;
    esac
    menu_security
}

# =========================================================
# 主入口
# =========================================================
main_menu() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "           ${CYAN}Docker 终极全能运维脚本 (V9.0 终极完整版)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e "  ${PURPLE}[1] 镜像管理 (Images)${NC}"
    echo -e "     • 常用: Pull, Search, Push, Inspect, Tag"
    echo -e "     • 维护: Save/Load (导入导出), Prune (清理), History"

    echo -e "  ${GREEN}[2] 容器管理 (Containers)${NC}"
    echo -e "     • 生命周期: Start, Stop, Kill, Restart, Pause"
    echo -e "     • 运维调试: Logs, Exec, CP (拷贝), Top, Stats"

    echo -e "  ${YELLOW}[3] 项目管理 (Compose)${NC} ${RED}<-- 已补全所有指令${NC}"
    echo -e "     • ${CYAN}构建销毁:${NC} Up -d, Down, Down -v (含卷)"
    echo -e "     • ${CYAN}服务控制:${NC} Start, Stop, Pause, Unpause, Kill"
    echo -e "     • ${CYAN}项目信息:${NC} Logs, Top, Images, Events, Config"
    echo -e "     • ${CYAN}高级升级:${NC} 标准升级(Pull), 编译升级(Build)"

    echo -e "  ${BLUE}[4] 系统运维 (System)${NC}"
    echo -e "     • 资源: DF (磁盘分析), Network, Volume"
    echo -e "     • 网络: Create, Remove, Connect, Disconnect"
    echo -e "     • 维护: Prune, Install, 镜像加速, 服务日志"

    echo -e "  ${PURPLE}[5] 镜像构建 (Build)${NC}"
    echo -e "     • 构建: Standard, No-cache, Multi-stage, BuildArg"
    echo -e "     • 高级: Buildx 多平台构建, 构建缓存管理"

    echo -e "  ${RED}[6] 安全诊断 (Security)${NC}"
    echo -e "     • 检查: 特权容器, Root用户, 网络模式, PID模式"
    echo -e "     • 诊断: 健康状态, 资源限制, 挂载卷, 日志清理"
    echo -e "     • 基线: 一键安全基线扫描 (5项综合检测)"

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
        5) menu_build ;;
        6) menu_security ;;
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
