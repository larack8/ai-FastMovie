# FastMovie Vue Frontend
# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# 复制 package 文件
COPY package*.json ./

# 安装依赖
RUN npm ci --registry=https://registry.npmmirror.com || npm install --registry=https://registry.npmmirror.com

# 复制源代码
COPY . .

# 设置生产环境 API 地址
ENV VITE_REQUEST_BASE_URL=http://localhost:7012

# 构建生产版本
RUN npm run build

# Stage 2: Production
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html/fastmovie

# 复制 nginx 配置
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
