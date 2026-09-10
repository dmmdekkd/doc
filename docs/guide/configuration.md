---
title: 配置
description: cookie.json / bot.json 字段说明
---
## 配置

`cookie.json`（账号，`login` 自动写入）：

```json
{
  "id": "main",
  "name": "主号",
  "cookie": "sessionid=...; ...",
  "phone": "",
  "uid": "1234567890",
  "device_id": "3249781169",
  "proxy": "",
  "channel": 1,
  "enabled": true
}
```

> 只想用验证码登录：`{ "phone": "13800138000", "enabled": true }` 即可，`cookie`/`uid` 登录后自动补全。

`bot.json`（网关，首次启动自动生成，`token` 随机）：

```json
{
  "host": "127.0.0.1",
  "port": 9503,
  "token": "<自动生成>",
  "queue_limit": 1000,
  "emit_self": false,
  "send_channel": "http"
}
```

> `send_channel`：`http`（默认，走 imapi）或 `ws`（走安卓 frontier WS）。二者内容 / 会话逻辑完全一致，只是传输外壳不同。**群聊在 HTTP 通道可能被风控拒（status_code 7523），此时切 `ws` 用安卓端身份绕开。**

| 字段 | 说明 |
|---|---|
| `host` / `port` | 网关监听地址，默认 `127.0.0.1:9503` |
| `token` | 鉴权令牌，首次随机生成 |
| `queue_limit` | 每连接事件队列上限 |
| `emit_self` | 是否下推自己发的消息（`message_self`）|
| `send_channel` | `http` / `ws` |
