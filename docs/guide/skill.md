---
title: AI Skill（Agent 知识包）
description: 一键安装到 Trae / Cursor / Claude Code 等 IDE，让 AI 理解本项目
---

## AI Skill（Agent 知识包）

本仓库自带一个 **jumpbyte-bot Skill**（`.trae/skills/jumpbyte-bot/SKILL.md`），把项目的架构、协议、算法、网关 API、构建测试命令与文档维护规则固化成了 AI 可直接读取的知识包。安装后，AI Agent 打开项目即可理解全貌，并正确回答、修改与维护。

### 支持的环境

| IDE / Agent | 安装目录 | 说明 |
|---|---|---|
| Trae | `.trae/skills/jumpbyte-bot/` | 仓库已自带，无需安装 |
| Cursor | `.cursor/skills/jumpbyte-bot/` | |
| Claude Code / Cline | `.claude/skills/jumpbyte-bot/` | |
| Cline | `.cline/skills/jumpbyte-bot/` | |
| Continue | `.continue/skills/jumpbyte-bot/` | |
| GitHub Copilot | `.github/skills/jumpbyte-bot/` | |
| VS Code / JetBrains | 经 Cline / Continue 插件加载 | 无原生 skills 目录 |

> VS Code 与 JetBrains 系列没有原生 skills 目录，安装对应的 Cline / Continue 插件后即可使用同一份 Skill。

### 一键安装（本地模式）

已克隆仓库时，直接运行仓库内脚本：

```bash
./scripts/install-skill.sh                  # 自动检测并安装到当前环境
./scripts/install-skill.sh --all            # 安装到全部支持的 IDE
./scripts/install-skill.sh --ide=trae,cursor,claude   # 只安装指定的 IDE
./scripts/install-skill.sh --list           # 查看支持的目标
./scripts/install-skill.sh --ide=trae --force        # 强制覆盖已存在的副本
```

Windows（PowerShell）：

```powershell
.\scripts\install-skill.ps1 -All
.\scripts\install-skill.ps1 -Ide "trae,cursor"
.\scripts\install-skill.ps1 -List
```

### 远程一键安装（无需克隆仓库）

不需要克隆仓库，直接在终端执行一条命令即可安装到**用户全局目录**（对所有项目生效）。更新 Skill 时重跑同一条命令即可。

**Linux / macOS / Windows（Git Bash / WSL）**：

```bash
curl -fsSL https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.sh | bash -s -- --all
```

只装指定 IDE：

```bash
curl -fsSL https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.sh | bash -s -- --ide=trae,cursor
```

**Windows 原生 PowerShell**：

```powershell
irm https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.ps1 | iex
```

带参数（如只装 Trae 和 Cursor）：

```powershell
iex "& { $(irm https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.ps1) } -Ide trae,cursor"
```

> 国内网络访问 `raw.githubusercontent.com` 不稳定时，可设置 `SKILL_RAW_URL` 指向镜像加速地址（bash / PowerShell 均支持）。

脚本以 `.trae/skills/jumpbyte-bot/SKILL.md` 为**唯一权威源**：本地模式读取仓库内的权威源并复制到各 IDE 目录；远程模式自动从 GitHub 下载最新权威源后安装到用户全局目录。修改 Skill 后重新运行脚本即可同步。

### Skill 包含什么

- **项目是什么**：IM 协议逆向客户端 + Go 单二进制 + 网关 + VitePress 文档站
- **架构分层**：`cmd/bot` 入口 → `internal/engine` 引擎 → 算法 / 登录 / 媒体 / 网关 / 配置
- **核心概念**：收消息 WS 全流程、发消息 HTTP/WS 双通道、`sign` / `a_bogus` 算法、媒体加解密
- **网关 API**：`/ws`、`/oriws`、`/api/*`、`/health`、`/img`、`/video` 及鉴权与动作清单
- **常用命令**：构建、运行、登录、自检、联机测试与调试技巧
- **文档维护指南**：VitePress 结构、导航/侧边栏位置、`base: "/doc/"` 部署约定与写作规则