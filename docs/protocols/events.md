---
title: 事件协议
description: WS /ws 的 message / connect / disconnect 与背压设计
---
## 网关事件协议（WS `/ws`）

连上 `ws://HOST:PORT/ws?access_token=TOKEN`，先收 `hello`，之后单向下推事件。上行只认 `{"type":"ping"}` → 回 `pong`。

### `hello`

```jsonc
{ "type": "hello", "protocol": 1, "accounts": [ … ] }
```

### `message`

```jsonc
{ "type": "message", "id": "8e3f…", "time": 1787735984,
  "account": "main", "self_uid": "1234",
  "conv_id": "0:1:1234:5678",   // 群聊时为纯数字群号
  "is_group": false,
  "sender_id": "5678", "sender_sec_uid": "MS4wLjAB…",
  "text": "在吗",
  "image": { "oid": "…", "skey": "…", "link": "http://…/img?u=…&k=…", "links": { … } } }
```

- 图片带 `url`(加密原图)+`link`(解密代理)+各档 `links`；视频带 `tkey/skey`+`play_url`(本地解密明文 MP4)+`poster`；表情 `url` 明文图无需解密。
- 拿 `conv_id` 调 `send_text` 即回复，`send_reply` 即引用回复。

### `message_self` / `connect` / `disconnect`

- `message_self`：自己发的消息，`emit_self=true` 才推。
- `reason`：`online` / `disconnect` / `stop` / `NETWORK` / `INVALID`。

### 背压设计

每个 WS 连接 `wsClient{conn, out chan, done}` + 独立 `writeLoop`（30s ping，写超时 10s）；`push` **非阻塞**：队列满先丢最旧再塞、还满就放弃，**绝不阻塞广播方（收包线程）**。
