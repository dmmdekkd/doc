---
title: 简介
description: 项目背景、用途与技术栈
---
## 项目简介

`jumpbyte-bot` 是一个用 Go 实现的抖音 IM（即时通讯）协议客户端 / 网关，单静态二进制，支持扫码 / 手机号登录、私信 + 群聊收发、图片 / 视频 / 表情 / 回复 / 撤回，并通过本地 HTTP + WebSocket 网关暴露成类 QQ-bot 的接口（详见[网关 API](/api/gateway)）。

**核心特征**：服务端没有公开 `.proto`，因此项目用「裸 / 宽松 protobuf」编解码 + 内嵌 JSON 双路径解析，所有请求带签名，媒体资源对称加密。整体是对真机安卓端 + Web SDK 行为的逆向还原。

### 技术栈

- 语言：**Go 1.25**，单静态二进制（`CGO_ENABLED=0`）
- WebSocket：`github.com/gorilla/websocket`
- 二维码：`github.com/liyue201/goqr`、`rsc.io/qr`
- 缓存：`modernc.org/sqlite`（昵称缓存）
- 无其他重量级框架，全部自实现

### 状态

单账号。`send_card` / `send_action_card` / 点赞未实现。`message_self`（自己发的消息）需在 `bot.json` 里开 `emit_self`。

> ⚠️ 本项目仅供学习、研究与技术交流，请遵守所在地法律法规与相关平台服务条款，勿用于违规场景。
