---
title: 网关 API
description: 端点、动作、事件与回声 Bot 示例
---
## 网关 API（`internal/gateway/`）

协议版本 **1**。默认地址 `127.0.0.1:9503`，令牌在 `bot.json`（首次启动自动生成）。

| 端点 | 用途 |
|---|---|
| `ws://HOST:PORT/ws?access_token=TOKEN` | 事件流（连上先 `hello`，之后单向下推）|
| `ws://HOST:PORT/oriws?access_token=TOKEN` | 原始 protobuf 帧（调试 / 逆向）|
| `POST /api/{动作}` | 发消息 / 撤回 / 上传 / 会话，`Authorization: Bearer` |
| `GET /health` | 存活 + 账号状态，免鉴权 |
| `GET /img?u=&k=` `/video?tkey=&skey=` | 图片 / 视频解密代理 |

### 通用约定

**鉴权**：HTTP 用 `Authorization: Bearer <TOKEN>`，WS 用 `?access_token=<TOKEN>`。

**响应**：`{ "code": 0, "data": { … } }` 成功；`{ "code": 400, "msg": "..." }` 失败。

| code | 含义 |
|---|---|
| 0 | 成功 |
| 400 | 参数不对 |
| 401 | 令牌无效 |
| 404 | 未知动作 / 路径 |
| 405 | 该动作只接受 POST |
| 500 | 执行失败 |

### 指定目标（发送类共用）

| 字段 | 必填 | 说明 |
|---|---|---|
| `conv_id` | 二选一 | 会话 ID（私信或群聊都用它）|
| `to_uid` | 二选一 | 目标数字 uid，网关自动拼**私信**会话 |
| `conv_short_id` | 否 | 已知更稳 |
| `account` | 否 | 单账号可省 |

`conv_id`：**私信** `0:1:{较小uid}:{较大uid}`（数值排序）；**群聊** 纯数字群号。

### 动作一览

`knownAction`：`get_accounts / send_text / send_image / upload_image / send_emoji / send_reply / send_video / recall / get_video_url / get_conversations`（`send_card`/`send_action_card` 未实现）。统一 `POST` + JSON + token。

**发送类返回**：`{client_msg_id, server_msg_id, prev_msg_id, conv_id, conversation_short_id, self_uid}`。

### 典型调用

```bash
BASE=http://127.0.0.1:9503
TOKEN=$(python -c "import json;print(json.load(open('bot.json'))['token'])")

# 发文本
curl -s -X POST $BASE/api/send_text -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" -d '{"conv_id":"0:1:1234:5678","text":"你好"}'

# 上传图片 → 发图片
IMG=$(curl -s -X POST $BASE/api/upload_image ... -d "{\"data\":\"$(base64 -w0 photo.jpg)\"}")
curl -s -X POST $BASE/api/send_image ... -d '{"conv_id":"...","image":'$IMG'}'

# 撤回
curl -s -X POST $BASE/api/recall ... -d '{"conv_id":"...","server_msg_id":"7678..."}'

# 视频播放地址 / 会话列表
curl -s -X POST $BASE/api/get_video_url ... -d '{"tkey":"...","skey":"..."}'
curl -s -X POST $BASE/api/get_conversations ... -d '{"count":50}'
```

### 原始帧 `/oriws`

`EmitRaw` 只在**有订阅者时才解码**：`{type:"raw", time, len, b64, fields:[{f,t,v}]}`，`fields` 即 `DecodeToTree` 输出，用于对照抓包分析未支持的消息类型。

### 回声 Bot

```bash
websocat "ws://127.0.0.1:9503/ws?access_token=$TOKEN" | while read -r line; do
  type=$(echo "$line" | python -c "import sys,json;print(json.load(sys.stdin).get('type',''))")
  [ "$type" = "message" ] || continue
  conv=$(echo "$line" | python -c "import sys,json;print(json.load(sys.stdin)['conv_id'])")
  text=$(echo "$line" | python -c "import sys,json;print(json.load(sys.stdin)['text'])")
  curl -s -X POST $BASE/api/send_text -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" -d "{\"conv_id\":\"$conv\",\"text\":\"你说：$text\"}"
done
```

`message_self`（自己发的消息）默认不推，在 `bot.json` 开 `emit_self` 后以 `message_self` 事件下推。
