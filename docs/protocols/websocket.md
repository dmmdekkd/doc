---
title: WebSocket 协议
description: 连接、帧模型、心跳与死亡检测
---
## WebSocket 协议

### 收消息连接

| 项 | 值 |
|---|---|
| URL | `wss://frontier-aweme-lf-ipainner.amemv.com/ws/v2` |
| 子协议 | `pbbp2`（`Sec-WebSocket-Protocol`）|
| 查询参数 | `aid=1128`、`version_code=280400`、`device_platform=android`、`access_key`、`ts`、`_rticket`、`ping-interval=30` 等几十项 |
| 请求头 | `User-Agent`、`Cookie`、`session-tlb-tag`、`x-tt-passport-mfa-token` 等 |

`access_key = md5(akFpID + akAppKey + deviceID + akSalt)`（`computeAccessKey`）。

### 帧模型

- 全部 **二进制帧**（`websocket.BinaryMessage`）。
- `WsConn.reader()` 单 goroutine 读帧 → 送进 `msgs` 缓冲 channel（cap 256）；`Receive(timeout)` 超时轮询；`Send` 写帧（加锁）；`Ping`/`Close` 控制帧。
- 支持 SOCKS5 / HTTP 代理（`applyProxy`），尊重 `HTTP(S)_PROXY`。

### 心跳与死亡检测（`RunSession`）

- 15s 心跳 ticker；**40s 收不到任何帧判定死亡** → 返回原因触发重连。
- 每收到一帧更新 `lastRecv`；`OnRaw` 回调（→ 网关 `/oriws`）。

### 发送用 WS（安卓 frontier，绕风控）

见[发送流程 §2](/guide/send-flow)。帧为三层嵌套 protobuf，回执经 `drainSendAck`（4s 超时）。
