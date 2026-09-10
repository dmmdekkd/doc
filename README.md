# jumpbyte-bot 技术文档

基于真实源码版本对齐生成的 **jumpbyte-bot（IM 协议逆向研究实现）** 完整整理文档，使用 [VitePress](https://vitepress.dev/) 构建。

收消息走 WebSocket，发消息 HTTP / WS 双通道 · 裸 protobuf · 媒体 AES-GCM / CENC 解密。

- 在线文档：https://dmmdekkd.github.io/doc/
- 技术栈：Node.js ≥ 18 · VitePress ^1.5 · pnpm

## 目录结构

```
docs-site/
├── docs/                      # 文档源文件（VitePress 根目录）
│   ├── .vitepress/            # 站点配置（config、sidebar、theme）
│   ├── index.md               # 首页
│   ├── guide/                 # 指南：架构总览、收发流程、AI Skill 安装等
│   ├── protocols/             # 协议：WebSocket、字段定义
│   ├── algorithms/            # 算法：sign / a_bogus(SM3+RC4) / 媒体加解密
│   ├── api/                   # 接口说明
│   └── modules/               # 源码模块：每包、每文件逐字节对齐的完整梳理
├── static-content/            # 静态资源（algorithms / api / guide / protocols）
├── .trae/skills/              # AI Skill 权威源（jumpbyte-bot/SKILL.md）
├── scripts/                   # 一键安装脚本（install-skill.sh）
├── .github/workflows/         # GitHub Actions：自动构建并部署到 Pages
├── package.json
└── pnpm-lock.yaml
```

## AI Skill 一键安装

让 AI 理解本项目的知识包，支持 Trae / Cursor / Claude Code / Cline / Continue / GitHub Copilot。

**远程一键安装（无需克隆仓库）：**

```bash
# Linux / macOS / Windows（Git Bash / WSL）
curl -fsSL https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.sh | bash -s -- --all
```

```powershell
# Windows 原生 PowerShell
irm https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.ps1 | iex
```

**本地安装（已克隆仓库）：**

```bash
./scripts/install-skill.sh --all          # bash
.\scripts\install-skill.ps1 -All          # PowerShell (Windows)
```

详见文档站：[AI Skill 安装](/doc/guide/skill)。

## 本地开发

需要 Node.js ≥ 18 与 pnpm。

```bash
pnpm install      # 安装依赖
pnpm dev          # 启动开发服务器（默认 http://localhost:5173）
pnpm build        # 构建静态站点到 docs/.vitepress/dist
pnpm preview      # 本地预览构建产物
```

## 在线部署

推送到 `main` 分支后，GitHub Actions（`.github/workflows/deploy-pages.yml`）会自动构建并部署到 GitHub Pages：

```
https://dmmdekkd.github.io/doc/
```

> 由于部署在 `doc` 项目仓库下，VitePress 配置了 `base: "/doc/"`，请勿移除该配置，否则静态资源路径会失效。

## 说明

本文档仅供学习研究使用，请遵守相关法律法规与服务条款。

## 许可

GPL-3.0