#!/bin/bash
# FastMovieAI 部署启动脚本
# 使用 Docker Compose 部署整个应用栈

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# 打印带颜色的消息
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 显示帮助
show_help() {
    cat << EOF
FastMovieAI 部署工具

用法: ./start.sh [命令]

命令:
    start       启动所有服务
    stop        停止所有服务
    restart     重启所有服务
    status      查看服务状态
    logs        查看日志 (可选: logs admin/frontend/mysql/redis)
    build       重新构建镜像
    down        停止并删除所有容器和数据卷
    ps          查看容器状态
    install     初始化安装
    test        测试服务可用性

端口说明:
    7010 - API 网关 (统一入口)
    7011 - 前端网站
    7012 - Admin 后端 API
    7013 - Push API
    7014 - Push WebSocket

EOF
}

# 检查 Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi

    print_success "Docker 环境检查通过"
}

# Docker Compose 命令封装
dc() {
    if docker compose version &> /dev/null 2>&1; then
        docker compose "$@"
    else
        docker-compose "$@"
    fi
}

# 启动服务
start_services() {
    print_info "启动 FastMovieAI 服务..."
    
    # 检查环境
    check_docker
    
    # 确保 install.lock 存在
    if [ ! -f fastmovie-admin/install.lock ]; then
        print_info "创建 install.lock 防止重复安装..."
        touch fastmovie-admin/install.lock
    fi
    
    # 启动服务
    dc up -d

    echo ""
    print_success "服务启动完成!"
    echo ""
    print_info "访问地址:"
    echo -e "  ${GREEN}API 网关:${NC}     http://localhost:7010"
    echo -e "  ${GREEN}前端网站:${NC}     http://localhost:7011"
    echo -e "  ${GREEN}Admin API:${NC}    http://localhost:7012 （ admin / admin123 ）"
    echo ""
    print_info "查看日志: ./start.sh logs"
    print_info "查看状态: ./start.sh status"
}

# 停止服务
stop_services() {
    print_info "停止 FastMovieAI 服务..."
    dc down
    print_success "服务已停止"
}

# 重启服务
restart_services() {
    print_info "重启 FastMovieAI 服务..."
    stop_services
    sleep 2
    start_services
}

# 查看状态
show_status() {
    print_info "服务状态:"
    dc ps
    echo ""
    
    print_info "端口映射:"
    echo "  7010 -> API 网关"
    echo "  7011 -> 前端网站"
    echo "  7012 -> Admin API"
    echo "  7013 -> Push API"
    echo "  7014 -> Push WSS"
    echo ""
    
    print_info "健康检查:"
    echo -n "  MySQL:  "; docker exec fastmovie-mysql mysqladmin ping -h localhost -u root -pfastmovie_root_2024 2>&1 | head -1 || echo "未运行"
    echo -n "  Redis:  "; docker exec fastmovie-redis redis-cli ping 2>/dev/null || echo "未运行"
    echo -n "  Admin:  "; curl -s -o /dev/null -w "%{http_code}" http://localhost:7012/ 2>/dev/null && echo "" || echo "未响应"
}

# 查看日志
show_logs() {
    local service=${1:-}
    if [ -n "$service" ]; then
        dc logs -f --tail=100 "$service"
    else
        dc logs -f --tail=50
    fi
}

# 构建镜像
build_images() {
    print_info "构建 Docker 镜像..."
    dc build --no-cache
    print_success "镜像构建完成"
}

# 完全清理
down_all() {
    print_warn "这将删除所有容器和数据卷!"
    read -p "确定要继续吗? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        dc down -v
        print_success "已清理所有容器和数据卷"
    else
        print_info "操作已取消"
    fi
}

# 初次安装
install_app() {
    print_info "开始初始化安装..."
    
    check_docker
    
    # 检查 vendor 目录
    if [ ! -d "fastmovie-admin/vendor" ]; then
        print_info "安装 PHP 依赖..."
        cd fastmovie-admin
        composer install --no-dev --optimize-autoloader || print_warn "Composer 依赖安装失败，将在容器内安装"
        cd ..
    fi
    
    # 创建必要目录
    mkdir -p fastmovie-admin/runtime/logs
    chmod -R 777 fastmovie-admin/runtime 2>/dev/null || true
    
    # 创建 install.lock
    touch fastmovie-admin/install.lock
    
    # 构建并启动
    build_images
    start_services
    
    print_success "初始化完成!"
    echo ""
    print_info "默认管理员账号:"
    echo "  用户名: admin"
    echo "  密码: admin123"
    echo ""
    print_warn "请登录后立即修改密码!"
}

# 测试服务
test_services() {
    print_info "测试服务可用性..."
    
    local errors=0
    
    echo -n "测试 MySQL 连接... "
    if docker exec fastmovie-mysql mysqladmin ping -h localhost -u root -pfastmovie_root_2024 &>/dev/null; then
        print_success "OK"
    else
        print_error "FAILED"
        ((errors++))
    fi
    
    echo -n "测试 Redis 连接... "
    if docker exec fastmovie-redis redis-cli ping 2>/dev/null | grep -q PONG; then
        print_success "OK"
    else
        print_error "FAILED"
        ((errors++))
    fi
    
    echo -n "测试 Admin API... "
    if curl -sf http://localhost:7012/ >/dev/null; then
        print_success "OK"
    else
        print_error "FAILED"
        ((errors++))
    fi
    
    echo -n "测试前端页面... "
    if curl -sf http://localhost:7011/fastmovie/ >/dev/null; then
        print_success "OK"
    else
        print_error "FAILED"
        ((errors++))
    fi
    
    echo -n "测试 API 网关... "
    if curl -sf http://localhost:7010/health >/dev/null; then
        print_success "OK"
    else
        print_error "FAILED"
        ((errors++))
    fi
    
    echo ""
    if [ $errors -eq 0 ]; then
        print_success "所有服务运行正常!"
    else
        print_error "$errors 个服务异常"
    fi
    
    return $errors
}

# 自动判断服务状态并执行相应操作
auto_services() {
    # 检查是否有容器在运行
    if dc ps -q 2>/dev/null | grep -q .; then
        print_info "检测到服务正在运行，执行重启..."
        restart_services
    else
        print_info "检测到服务未运行，执行启动..."
        start_services
    fi
}

# 主入口
case "${1:-}" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status|ps)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    build)
        build_images
        ;;
    down)
        down_all
        ;;
    install)
        install_app
        ;;
    test)
        test_services
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        # 不带参数时自动判断
        auto_services
        ;;
    *)
        print_error "未知命令: $1"
        show_help
        exit 1
        ;;
esac
