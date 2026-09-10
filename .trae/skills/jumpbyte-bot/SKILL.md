---
name: "jumpbyte-bot"
description: "jumpbyte-bot 项目（IM 协议逆向 + Go 单二进制 Bot + VitePress 文档站）的体系化知识。Invoke when the user asks about this project's architecture, message flows, protocols, algorithms, gateway API, how to build/test/run, or how to maintain its docs."
---

# jumpbyte-bot — 项目 Knowledge & 工作指南

本 Skill 聚合了「**IM 协议逆向研究实现**」`jumpbyte-bot` 项目的完整知识，供 AI Agent 在理解代码、回答问题、修改或维护文档时使用。技术栈：**Go**（单静态二进制 Bot）+ **VitePress**（文档站）。

- 在线文档：`https://dmmdekkd.github.io/doc/`
- 文档源目录：`docs/`（VitePress，`/doc/` 子路径部署）
- 文档描述对象是真实 Go 源码，源码版本 `main @ b252442 (2026-09-03)`，文档与源码逐字节对齐。

---

## 1. 项目是什么

一个**单账号 IM 协议客户端**（command-line bot），通过逆向协议实现消息收发：

- **收消息**：始终走 WebSocket 事件流。
- **发消息**：HTTP（imapi）或 WS（安卓 frontier）双通道。
- **底层**：裸 protobuf 编解码、请求签名（`sign`）、反爬签名（`a_bogus`）、媒体 AES-GCM / CENC 解密。

它同时是一个**对外网关服务**（HTTP + WS），终端/脚本可接入收发消息，并附带一个 VitePress 文档站复述全部原理。

---

## 2. 架构与分层

```
终端/脚本 ──HTTP──▲  /api/*  发消息/撤回/上传/会话
终端/脚本 ──WS────▲  /ws     事件流; /oriws 原始 protobuf 帧; /img /video 媒体代理
                 engine.Client (单账号 IM 引擎)
                  ├ WsConn(WS收发帧) ┐
                  ├ proto.go(裸protobuf)│
                  ├ httpsend.go(HTTP发)│── 共用同一套内容/会话逻辑，仅传输外壳不同
                  ├ wssend.go(WS发)    ┘
                  ├ imactions.go(撤回/表情/回复)
                  ├ upload.go/video.go(媒体上传)
                  └ convlist.go(会话列表)
        算法层: sign(xor5/sha256)、abogus(SM3+RC4+变体base64)
        media : AES-256-GCM / CENC-AES-128-CTR
```

| 层 | 源码路径 | 职责 |
|---|---|---|
| 入口 | `cmd/bot` | 命令分发、扫码登录、收发主循环、断线重连 |
| 引擎 | `internal/engine` | IM 核心：WS / protobuf / 收发 / 媒体上传 |
| 算法 | `internal/sign`、`internal/abogus` | 请求签名、反爬签名 |
| 登录 | `internal/login`、`internal/qr` | 扫码/短信/MFA/cookie 探测 |
| 媒体 | `internal/media` | 图片/视频解密 + 本地代理 |
| 网关 | `internal/gateway` | HTTP + WS 对外接口 |
| 配置 | `internal/config` | `cookie.json` / `bot.json` |

**关键设计**：收消息始终 WS，发消息 HTTP/WS 双通道；二者共用同一套裸 protobuf 编解码器（`proto.go`）和内容/会话逻辑。

---

## 3. 核心概念速查

### 3.1 接收消息流程
- 收包连接：`wss://frontier-aweme-lf-ipainner.amemv.com/ws/v2`，子协议 `pbbp2`，查询参数含 `aid=1128`、`version_code=280400`、`device_platform=android`、`ping-interval=30` 等几十项。
- `access_key = md5(akFpID + akAppKey + deviceID + akSalt)`（`computeAccessKey`）。
- 全部为**二进制帧**；`WsConn.reader()` 单 goroutine 读帧 → `msgs` 缓冲 channel(cap 256)；`Receive(timeout)` 超时轮询。
- 心跳/死亡：15s 心跳 ticker，**40s 收不到帧判定死亡** → 触发重连（指数退避 + cookie 失效自愈）。

### 3.2 发送消息流程
- 默认 **HTTP**（imapi）；切 `send_channel: "ws"` 用**安卓 frontier WS** 绕群聊风控（HTTP 通道群聊可能 `status_code 7523`）。
- 内容/会话逻辑与收包共用，仅传输外壳不同。

### 3.3 算法
| 算法 | 位置 | 用途 |
|---|---|---|
| `sign`/`qs`/`xor5`/`msToken` | `internal/sign` | 电脑版 passport web 请求签名 |
| `a_bogus` | `internal/abogus` | web 反爬签名（SM3+RC4+base64 变体）|
| 图片 AES-256-GCM | `internal/media/image.go` | 图片解密 |
| 视频 CENC-AES-128-CTR | `internal/media/cenc.go`、`mp4cenc.go` | 视频解密 |

### 3.4 配置文件
- `cookie.json`（账号）：`id`、`name`、`cookie`、`phone`、`uid`、`device_id`、`proxy`、`channel`、`enabled`。`login` 自动写入；只填 `phone` + `enabled` 即可验证码登录自愈。
- `bot.json`（网关）：`host`(默认 `127.0.0.1`)、`port`(默认 `9503`)、`token`(随机生成)、`queue_limit`、`emit_self`、`send_channel`(`http`/`ws`)。

---

## 4. 网关 API（`internal/gateway/`）

协议版本 **1**，默认 `127.0.0.1:9503`。

| 端点 | 用途 |
|---|---|
| `ws://HOST:PORT/ws?access_token=TOKEN` | 事件流（连上先 `hello`，单向下推）|
| `ws://HOST:PORT/oriws?access_token=TOKEN` | 原始 protobuf 帧（调试/逆向）|
| `POST /api/{动作}` | 发消息/撤回/上传/会话，`Authorization: Bearer` |
| `GET /health` | 存活+账号状态，免鉴权 |
| `GET /img?u=&k=` `/video?tkey=&skey=` | 图片/视频解密代理 |

- 鉴权：HTTP `Authorization: Bearer <TOKEN>`；WS `?access_token=<TOKEN>`。
- 响应：成功 `{code:0,data:{...}}`；失败 `{code:400,msg:"..."}`。code：0 成功 / 400 参数 / 401 令牌 / 404 未知动作 / 405 非 POST / 500 执行失败。
- 指定目标：`conv_id` 或 `to_uid` 二选一。会话 ID 规则：私信 `0:1:{较小uid}:{较大uid}`（数值排序）；群聊为纯数字群号。
- 已知动作：`get_accounts / send_text / send_image / upload_image / send_emoji / send_reply / send_video / recall / get_video_url / get_conversations`（`send_card`/`send_action_card` 未实现）。

---

## 5. 常用命令

```bash
# 构建（静态单二进制，输出 dist/jumpbyte-bot）
CGO_ENABLED=0 go build -ldflags="-s -w" -o dist/jumpbyte-bot ./cmd/bot

# 运行
jumpbyte-bot                # 探测 cookie(失效自动重登) → 连接 IM → 启动网关
jumpbyte-bot login          # 登录(有 phone 走验证码，否则扫码)，写 cookie.json
jumpbyte-bot --selftest     # 自检算法
jumpbyte-bot --smoke        # 给自己发测试消息，验证收发联机

# 测试（每个包均配套 _test.go）
go test ./...
```

**调试技巧**：
- 原始帧：`ws://HOST:PORT/oriws?access_token=TOKEN`，`fields` 为 `DecodeToTree` 输出。
- 抓包：设 `HTTP_PROXY`/`HTTPS_PROXY` → mitmproxy（`applyProxy` 尊重该环境变量）。
- 发消息换行：终端直接输入 `@<conv_id> <文本>` 回车。

---

## 6. 文档站维护指南

文档站是 VitePress 项目，位于仓库根 `docs/` 下。**此 Skill 的主要职责之一就是帮助维护这套文档。**

- 首页：`docs/index.md`（含导航 `features`）。
- 导航配置：`docs/.vitepress/config.js`；侧边栏：`docs/.vitepress/sidebar.js`；主题：`docs/.vitepress/theme/`。
- 部署基路径 `base: "/doc/"`（GitHub Pages 子路径，**勿移除**，否则资源 404）。
- 本地：`pnpm install` → `pnpm dev`（:5173）/ `pnpm build`（输出 `docs/.vitepress/dist`）。
- 文档结构：
  - `guide/` 简介/架构/快速开始/收发流程/配置/测试
  - `protocols/` WebSocket/protobuf/事件协议
  - `algorithms/` 总览/sign/a_bogus/媒体加解密
  - `api/` 网关 API
  - `modules/` 每个 Go 包的源码拆解与索引（`internal-*`/`cmd-bot`）

**文档写作规则**：与源码逐字节对齐；提交生成的 API 速览保留「函数 + 所在行号 + 一句话注释」风格；修改算法/协议后同步更新对应小节。

---

## 7. Skill 自身安装

本 Skill 已随仓库自带。将 `SKILL.md` 复制到各 IDE/Agent 的 skills 目录即可被识别：

```bash
./scripts/install-skill.sh        # 自动检测并安装到当前环境
./scripts/install-skill.sh --all # 安装到全部支持的 IDE
./scripts/install-skill.sh --ide=trae,cursor,claude
```

支持的 IDE/Agent 与目标目录：
| IDE / Agent | 目录 | 备注 |
|---|---|---|
| Trae | `.trae/skills/jumpbyte-bot/` | 仓库已自带，无需安装 |
| Cursor | `.cursor/skills/jumpbyte-bot/` | |
| Claude Code / Cline | `.claude/skills/jumpbyte-bot/` | |
| Continue | `.continue/skills/jumpbyte-bot/` | |
| VS Code | 经 Cline/Continue 插件加载 | 无原生 skills 目录 |
| JetBrains | 经 Cline/Continue 插件加载 | 同上 |

---

## 8. 维护者注意

- 本 Skill 由 `.trae/skills/jumpbyte-bot/SKILL.md` 作为唯一权威源，安装脚本从它复制到各 IDE，保持单一来源。
- 修改 Skill 后如同步推送，需重新运行 `install-skill.sh` 以更新各 IDE 中的副本。