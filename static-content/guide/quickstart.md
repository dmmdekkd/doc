---
title: 快速开始
description: 构建、运行与最小回声 Bot
---
## 快速开始

### 构建

```bash
CGO_ENABLED=0 go build -ldflags="-s -w" -o dist/jumpbyte-bot ./cmd/bot
```

### 命令

```
jumpbyte-bot              探测 cookie（失效自动重新登录）→ 连接 IM → 启动网关
jumpbyte-bot login        登录（有 phone 走验证码，否则扫码），写 cookie.json
jumpbyte-bot --selftest   自检算法
jumpbyte-bot --smoke      给自己发一条测试消息，验证收发联机
```

### 首次运行

无 `cookie.json` 时自动进入扫码登录，终端打印二维码并存 `qrcode.png`。`GOBOT_QR=braille` 切换为盲文点阵。

**手机号 + 验证码登录**：在 `cookie.json` 填 `phone`（`cookie` 留空），启动后自动发短信、终端提示输入验证码换取 cookie；之后 cookie 失效也会用同一手机号重登。手机号与验证码都用 `code_encrypt`（`XOR 5` + hex）加密。

### 最小回声 Bot

```bash
BASE=http://127.0.0.1:9503
TOKEN=$(python -c "import json;print(json.load(open('bot.json'))['token'])")

websocat "ws://127.0.0.1:9503/ws?access_token=$TOKEN" | while read -r line; do
  type=$(echo "$line" | python -c "import sys,json;print(json.load(sys.stdin).get('type',''))")
  [ "$type" = "message" ] || continue
  conv=$(echo "$line" | python -c "import sys,json;print(json.load(sys.stdin)['conv_id'])")
  text=$(echo "$line" | python -c "import sys,json;print(json.load(sys.stdin)['text'])")
  curl -s -X POST $BASE/api/send_text -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" -d "{\"conv_id\":\"$conv\",\"text\":\"你说：$text\"}"
done
```

启动后终端也可直接输入 `@<conv_id> <文本>` 回车发消息。
