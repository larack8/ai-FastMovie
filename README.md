<div align="center">

# ai-FastMovie

**Open-Source AI-Powered Short Drama Creation Platform**

[简体中文](README.zh.md) | [English](README.md)

![PHP](https://img.shields.io/badge/PHP-8.1+-777BB4?style=flat-square&logo=php&logoColor=white)
![Webman](https://img.shields.io/badge/Webman-2.1+-00ADD8?style=flat-square)
![Vue 3](https://img.shields.io/badge/Vue-3.5+-4FC08D?style=flat-square&logo=vue.js&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5.9+-3178C6?style=flat-square&logo=typescript&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-7.1+-646CFF?style=flat-square&logo=vite&logoColor=white)
![License](https://img.shields.io/badge/License-Apache%202.0-blue?style=flat-square)

</div>

---

## ✨ Overview

ai-FastMovie is a production-ready, open-source short drama creation platform with a decoupled frontend-backend architecture. It provides AI-driven video content creation capabilities including script generation, character management, voice synthesis, video editing, payment integration, and a complete user system — everything you need to build your own short drama SaaS.

<div align="center">
  <img src="./readme_assets/prereview_frontend.png" alt="Frontend Preview" width="100%" style="border-radius: 8px; margin: 8px 0;" />
  <img src="./readme_assets/prereview_backend.png" alt="Backend Admin Panel" width="100%" style="border-radius: 8px; margin: 8px 0;" />
</div>

### 🎯 Why ai-FastMovie?

| Feature | Description |
|---------|-------------|
| 🎬 **AI Video Creation** | AI-powered short drama generation and editing |
| 🎭 **Character Management** | Virtual character creation and configuration |
| 🎙️ **Voice Synthesis** | Multi-language TTS and dubbing |
| 📝 **Script Editor** | Visual storyboard and script management |
| 💰 **Payment System** | Alipay & WeChat Pay integration |
| 👥 **User & VIP System** | Registration, login, membership tiers |
| 🔌 **Plugin Architecture** | Modular design, easy to extend |
| 🌍 **Multi-language** | Chinese / English UI switching |

### 🏗️ Tech Stack

**Backend**
- PHP 8.1+ / Webman 2.1+ (Workerman-based high-performance framework)
- MySQL 8.0+, Redis
- ThinkORM, ThinkTemplate
- Yansongda/Pay (payment), php-ffmpeg (video), webman/push (WebSocket)

**Frontend**
- Vue 3.5+ (Composition API) / TypeScript 5.9+
- Vite 7.1+ / Element Plus 2.11+
- Pinia 3.0+ / Vue Router 4.5+

---

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose (recommended)
- Or manually: PHP ≥ 8.1, MySQL ≥ 8.0, Redis, Node.js LTS

### Option A: Docker One-Click Deploy (Recommended)

```bash
git clone https://github.com/larack8/ai-FastMovie.git
cd ai-FastMovie

# Start all services
docker-compose up -d
```

This launches the full stack:

| Service | Container | Port | Description |
|---------|-----------|------|-------------|
| Gateway | fastmovie-gateway | 7010 | API gateway (nginx) |
| Frontend | fastmovie-frontend | 7011 | Vue frontend |
| Admin API | fastmovie-admin | 7012-7014 | Backend API + WebSocket push |
| MySQL | fastmovie-mysql | 7015 | Database |
| Redis | fastmovie-redis | 7016 | Cache |

Access:
- **Frontend**: http://localhost:7010
- **Admin Panel**: http://localhost:7012/admin/
- **Default Account**: admin / 123456

> ⚠️ Change the default password after first login!

### Option B: Manual Deployment

```bash
git clone https://github.com/larack8/ai-FastMovie.git
cd ai-FastMovie

# 1. Backend setup
cd fastmovie-admin
cp .env.example .env        # Edit database & Redis config
php start.php start -d       # Start in daemon mode

# 2. Frontend setup (new terminal)
cd ../fastmovie-vue
npm install
npm run dev                 # Dev server on port 36310
```

Visit `http://your-domain/install` for the web-based installation wizard (environment check, DB init, config generation).

### Project Structure

```
ai-FastMovie/
├── fastmovie-admin/          # Backend (PHP/Webman)
│   ├── app/                  # Application code
│   ├── config/               # Configuration
│   ├── plugin/               # Plugin modules
│   ├── public/               # Web root
│   └── start.php             # Entry point
├── fastmovie-vue/            # Frontend (Vue3/TS)
│   ├── src/                  # Source code
│   └── vite.config.ts
├── docker/                   # Docker configs (nginx)
├── docker-compose.yml        # Full stack orchestration
├── start.sh                  # Deployment helper script
└── README.md
```

---

## 🔧 Configuration

### Environment Variables (.env)

Key configuration items in `fastmovie-admin/.env`:

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_PORT` | 7012 | Backend listen port |
| `DATABASE_HOST` | mysql | DB host (container name in Docker) |
| `DATABASE_PORT` | 3306 | DB port |
| `DATABASE_NAME` | ai_short_play | Database name |
| `REDIS_HOST` | redis | Redis host (container name) |
| `REDIS_PORT` | 6379 | Redis port |
| `PUSH_API_PORT` | 7013 | WebSocket push API port |
| `PUSH_WSS_PORT` | 7014 | WebSocket WSS port |

### Plugin System

ai-FastMovie uses a modular plugin architecture:

| Plugin | Function |
|--------|----------|
| **user** | User management & authentication |
| **finance** | Payment & billing |
| **marketing** | Promotions & campaigns |
| **article** | CMS content management |
| **shortplay** | Core short drama creation |
| **model** | AI model integration |
| **notification** | Push notifications |
| **control** | Platform settings |

Each plugin can be independently enabled or disabled.

---

## 📖 Documentation

- [Backend Development Guide](./docs/backend-development.md) — Webman/PHP development
- [Frontend Development Guide](./docs/frontend-development.md) — Vue3/TypeScript development

### Common Commands

```bash
# Backend
cd fastmovie-admin
php start.php start     # Start
php start.php stop      # Stop
php start.php restart   # Restart
php start.php status    # Status
php webman              # List all commands

# Frontend
cd fastmovie-vue
npm run dev             # Development server
npm run build           # Production build
vue-tsc --noEmit        # Type check
```

---

## 🤝 Contributing

We welcome contributions of all kinds — bug reports, feature proposals, documentation improvements, and code submissions.

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to your branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

**Guidelines**: PSR-12 for backend code, ESLint/Prettier for frontend, clear commit messages.

---

## 📄 License

This project is licensed under [Apache License 2.0](./LICENSE).

## ⚠️ Disclaimer

For learning and research purposes only. Users are responsible for compliance with applicable laws and regulations.

---

## 💬 Contact & Community

- **Email**: larack@126.com
- **Issues**: [GitHub Issues](https://github.com/larack8/ai-FastMovie/issues)

<div align="center">

<table>
  <tr>
    <td align="center">
      <img src="./readme_assets/shoukuan.png" width="180" alt="User Community" />
      <br />
      <b>User Community</b>
      <br />
      <span>Join creators' discussion</span>
    </td>
    <td align="center">
      <img src="./readme_assets/miniapp_logo.png" width="180" alt="Business Cooperation" />
      <br />
      <b>Business Cooperation</b>
      <br />
      <span>Tech consulting & partnership</span>
    </td>
  </tr>
</table>

<br />

If this project helps you, give it a ⭐️ Star!

Made with ❤️ by ai-FastMovie Team

</div>
