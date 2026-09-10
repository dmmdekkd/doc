---
title: 架构总览
description: cmd → engine → gateway 分层与目录结构
---
## 架构总览

```
                    ┌──────────── 外网 (Douyin IM) ────────────┐
                    │                                            │
  终端/脚本 ──HTTP──▶│── /api/*  发消息/撤回/上传/会话 (imapi)    │◀── 发 (默认 http)
  终端/脚本 ──WS────▶│── /ws     事件流(message/connect/disconnect)│── 收 (始终 WS)
                    │── /oriws  原始 protobuf 帧(调试)            │
                    │── /img /video  媒体解密代理                  │
                    │                                            │
                    │   engine.Client (单账号 IM 引擎)             │
                    │   ├─ WsConn   ── WebSocket 连接/收发帧      │
                    │   ├─ proto.go  ── 裸 protobuf 编解码        │
                    │   ├─ httpsend.go── 发: HTTP(imapi)          │
                    │   ├─ wssend.go  ── 发: WS(frontier 安卓)    │
                    │   ├─ imactions.go── 撤回/表情/回复          │
                    │   ├─ upload.go / video.go ── 媒体上传       │
                    │   └─ convlist.go ── 会话列表                │
                    └────────────────────────────────────────────┘
                              ▲
                              │ 算法层: sign(xor5/sha256)、abogus(SM3+RC4+变体base64)
                              │ media: AES-256-GCM / CENC-AES-128-CTR
```

### 分层

| 层 | 路径 | 职责 |
|---|---|---|
| 入口 | `cmd/bot` | 命令分发、扫码登录、收发主循环、断线重连 |
| 引擎 | `internal/engine` | IM 核心：WS / protobuf / 收发 / 媒体上传 |
| 算法 | `internal/sign`、`internal/abogus` | 请求签名、反爬签名 |
| 登录 | `internal/login`、`internal/qr` | 扫码 / 短信 / MFA / cookie 探测 |
| 媒体 | `internal/media` | 图片 / 视频解密 + 本地代理 |
| 网关 | `internal/gateway` | HTTP + WS 对外接口 |
| 配置 | `internal/config` | `cookie.json` / `bot.json` |

**关键设计**：收消息始终 WS，发消息 HTTP / WS 双通道；二者共用同一套裸 protobuf 编解码器（`proto.go`）和同一套内容 / 会话逻辑，仅「传输外壳」不同。详见[接收流程](/guide/receive-flow)与[发送流程](/guide/send-flow)。

### 目录结构

```
cmd/bot             入口: 命令分发、扫码登录、收发主循环
internal/
  sign              passport web 签名 (sign / qs / xor5 / msToken)
  abogus            a_bogus (SM3 + RC4 变体 + base64 变体)
  login             扫码 / 手机号验证码登录、MFA、cookie 探测
  qr                二维码渲染 + 存 PNG
  engine            IM 引擎 ← 收发/WS/protobuf 核心
  media             图片 AES-256-GCM 解密 + 视频 CENC 解密 + 本地代理
  webapi            昵称解析 (带缓存)
  store             sqlite 昵称缓存
  gateway           HTTP + WS 网关
  config            cookie.json / bot.json
```
