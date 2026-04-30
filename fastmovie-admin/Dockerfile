# FastMovie Admin - PHP Webman Backend
FROM php:8.2-cli-alpine

# 安装系统依赖
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    oniguruma-dev \
    redis \
    mysql-client \
    ffmpeg \
    procps \
    linux-headers \
    libevent-dev \
    openssl-dev \
    brotli-dev \
    $PHPIZE_DEPS

# 安装 PHP 扩展
RUN docker-php-ext-install \
    pdo_mysql \
    mysqli \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    sockets \
    opcache

# 安装 Redis 扩展
RUN pecl install redis && docker-php-ext-enable redis

# 安装 Swoole 扩展（无 brotli/zstd 避免额外依赖）
RUN printf 'no\nno\nno\nno\nno\nno\nno\nno\nno\nno\n' | pecl install swoole && docker-php-ext-enable swoole

# 安装 Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 设置工作目录
WORKDIR /var/www/html

# 复制项目文件
COPY . .

# 安装 PHP 依赖
RUN composer install --no-dev --optimize-autoloader --no-interaction || true

# 创建运行时目录
RUN mkdir -p runtime/logs runtime/cache && chmod -R 777 runtime

# 创建 .env 文件
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# 暴露端口
EXPOSE 7012 7013 7014

# 启动脚本
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php", "start.php", "start"]
