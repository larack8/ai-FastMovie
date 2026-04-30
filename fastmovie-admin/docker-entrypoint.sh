#!/bin/sh
set -e

echo "=== FastMovie Admin Startup ==="
echo "Waiting for MySQL and Redis..."

# 等待 MySQL 就绪
until nc -z mysql 3306; do
  echo "MySQL is unavailable - sleeping"
  sleep 2
done
echo "MySQL is up!"

# 等待 Redis 就绪
until nc -z redis 6379; do
  echo "Redis is unavailable - sleeping"
  sleep 2
done
echo "Redis is up!"

# 等待几秒确保服务完全就绪
sleep 5

# 确保 .env 文件存在
if [ ! -f .env ]; then
  echo "Creating .env from .env.example..."
  cp .env.example .env
fi

# 更新 .env 配置
echo "Updating .env configuration..."
sed -i "s/^SERVER_PORT=.*/SERVER_PORT=${SERVER_PORT:-7012}/" .env
sed -i "s/^DATABASE_HOST=.*/DATABASE_HOST=${DATABASE_HOST:-mysql}/" .env
sed -i "s/^DATABASE_PORT=.*/DATABASE_PORT=${DATABASE_PORT:-3306}/" .env
sed -i "s/^DATABASE_NAME=.*/DATABASE_NAME=${DATABASE_NAME:-ai_short_play}/" .env
sed -i "s/^DATABASE_USERNAME=.*/DATABASE_USERNAME=${DATABASE_USERNAME:-fastmovie}/" .env
sed -i "s/^DATABASE_PASSWORD=.*/DATABASE_PASSWORD=${DATABASE_PASSWORD:-fastmovie_2024}/" .env
sed -i "s/^REDIS_HOST=.*/REDIS_HOST=${REDIS_HOST:-redis}/" .env
sed -i "s/^REDIS_PORT=.*/REDIS_PORT=${REDIS_PORT:-6379}/" .env

# 检查数据库是否已初始化
echo "Checking database initialization..."
TABLE_COUNT=$(mysql -h${DATABASE_HOST:-mysql} -u${DATABASE_USERNAME:-fastmovie} -p${DATABASE_PASSWORD:-fastmovie_2024} ${DATABASE_NAME:-ai_short_play} -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DATABASE_NAME:-ai_short_play}'" -sN --skip-ssl 2>/dev/null || echo "0")

if [ "$TABLE_COUNT" = "0" ] || [ -z "$TABLE_COUNT" ]; then
  echo "Database tables not found. Initializing..."
  mysql -h${DATABASE_HOST:-mysql} -u${DATABASE_USERNAME:-fastmovie} -p${DATABASE_PASSWORD:-fastmovie_2024} ${DATABASE_NAME:-ai_short_play} --skip-ssl < /docker-entrypoint-initdb.d/init.sql 2>/dev/null || echo "Database init may have failed, but continuing..."
  echo "Database initialization completed."
else
  echo "Database already initialized ($TABLE_COUNT tables found)."
fi

# 创建默认管理员账号（如果不存在）
echo "Creating default admin account..."
cat > /tmp/create_admin.php << 'PHPEOF'
<?php
$pdo = new PDO("mysql:host=mysql;dbname=ai_short_play", "fastmovie", "fastmovie_2024");
$hash = password_hash("admin123", PASSWORD_BCRYPT);
$pdo->exec("DELETE FROM php_admin WHERE id=1");
$now = date("Y-m-d H:i:s");
$stmt = $pdo->prepare("INSERT INTO php_admin (id,username,password,nickname,role_id,state,create_time,update_time) VALUES (1,?,?,?,1,1,?,?)");
$stmt->execute(["admin",$hash,"超级管理员",$now,$now]);
echo "Admin account created: admin / admin123\n";
PHPEOF
php /tmp/create_admin.php 2>/dev/null || echo "Admin account setup skipped"
rm -f /tmp/create_admin.php

# 创建 install.lock 防止重新安装
if [ ! -f install.lock ]; then
    echo "Creating install.lock..."
    touch install.lock
fi

# 确保运行时目录权限
chmod -R 777 runtime 2>/dev/null || true

echo "==============================================="
echo "FastMovie AI 启动完成"
echo "==============================================="
echo "Admin 后台: http://localhost:7012/admin/"
echo "默认账号:   admin"
echo "默认密码:   admin123"
echo "==============================================="

echo "Starting Webman server..."
echo "Admin API: http://localhost:${SERVER_PORT:-7012}"
echo "Push API: http://localhost:${PUSH_API_PORT:-7013}"
echo "Push WSS: ws://localhost:${PUSH_WSS_PORT:-7014}"

# 执行传入的命令
exec "$@"