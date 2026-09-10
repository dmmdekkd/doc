---
title: 接收消息流程
description: WebSocket 全链路：建连 → 心跳 → 读帧 → protobuf 解码 → 组装 IncomingMessage
---
## 接收消息流程（WebSocket）

收消息**始终走 WebSocket**，连接到抖音 frontier IM 长连接 `wss://frontier-aweme-lf-ipainner.amemv.com/ws/v2`，子协议 `pbbp2`。链路：**建连 → 心跳 → 读帧 → protobuf 宽松解码 → 抠 JSON 消息体 → 组装 IncomingMessage → 投递**。

### 1. 建连（`client.go`）

`Connect()` → `buildAndroidSendWsURL()` 拼出带签名的 WS URL，`makeClient()` 设置 UA / Cookie / `Sec-WebSocket-Protocol: pbbp2` 等头，最终 `wsConnect()` 握手。

```go
const androidSendWsBase = "wss://frontier-aweme-lf-ipainner.amemv.com/ws/v2"

// access_key = md5("9" + akAppKey + deviceID + "f8a69f1719916z")
func (c *Client) computeAccessKey(deviceID string) string {
    sum := md5.Sum([]byte(akFpID + akAppKey + deviceID + akSalt))
    return hex.EncodeToString(sum[:])
}
```

URL 查询参数（逆自真机安卓端）含 `aid=1128`、`version_code=280400`、`device_platform=android`、`access_key`、时间戳 `ts/_rticket`、`ping-interval=30` 等几十项。

### 2. WebSocket 连接对象（`wsconn.go`）

`WsConn` 封装 gorilla/websocket：`reader()` goroutine 把每帧二进制数据送进 `msgs` 缓冲 channel（容量 256），`Receive(timeout)` 支持超时轮询，`Send()` 写二进制帧，`Ping()` 发控制帧，`Close()` 发 Close 帧。支持 SOCKS5 / HTTP 代理（`applyProxy`），尊重 `HTTP(S)_PROXY` 环境变量方便抓包。

```go
func (c *WsConn) reader() {
    for {
        _, data, err := c.ws.ReadMessage()
        if err != nil { c.setClosed(err); return }
        select {
        case c.msgs <- data:   // 入队
        case <-c.done: return
        }
    }
}
func (c *WsConn) Send(data []byte) error { return c.ws.WriteMessage(websocket.BinaryMessage, data) }
```

### 3. 收发主循环（`client.go` RunSession）

`RunSession` 是收消息总控：起一个 15s 心跳 ticker（40s 收不到任何帧判定死亡），主循环 `conn.Receive(1s)` 拿原始 payload → 更新 `lastRecv` → 回调 `OnRaw`（调试原始帧）→ `handleIncoming` 解析并投递。

```go
for {
    raw, err := conn.Receive(time.Second)
    if err != nil { break }
    if raw != nil { lastRecv.Store(time.Now().Unix()) }
    if len(raw) == 0 { continue }
    if c.OnRaw != nil { c.OnRaw(raw) }  // → 网关 /oriws
    c.handleIncoming(raw, onMessage)
}
```

### 4. 收包解析（`handleIncoming` + `extractChatItems`）

由于 **imapi 没有公开 .proto**，用**宽松 protobuf 解码**（见[Protobuf 编解码](/protocols/protobuf)）：先 `decodeTop(payload)` 得字段树，再 `collectChat` 两遍扫描：

- **pass 1**：提取上下文——`field=7` 为 sender、`0:1:x:y` 形态字符串为 conv_id、`field=14` 以 `MS4` 开头为 sec_uid。
- **pass 2**：遍历所有 string 字段，尝试 `json.Unmarshal`；命中 `text`/`aweType`/`tkey` 的当消息 JSON，交 `parseChatJsonItem` 解析文本 / 图片 / 视频 / 表情。
- **兜底**：protobuf 路径没抠出条目，用正则 `0:1:\d+:\d+` + JSON 片段直接从裸字节再捞一遍（`collectChatFromRawJson`）。

最终组装 `IncomingMessage{ConvID, IsGroup, SenderID, SenderMs4, Text, AweType, Image, Video, Emoji, Direction}`。

- **会话 ID**：私信 `0:1:{较小uid}:{较大uid}`（`BuildConvID`，按数值排序）；群聊是纯数字群号 → `IsGroup=true`。
- **short_id 学习**：收包时抠出 `conv_short_id` 缓存到 `Client.shortIDs`，发送时回填。
- **方向**：`sender == selfUid` 为 `sent`，否则 `recv`。`message_self` 默认不推，需 `emit_self=true`。

### 5. 上层投递与重连（`cmd/bot/main.go`）

投递时若 `gw != nil` 调用 `gw.EmitMessage(m)`（非阻塞），只打印 `Direction=="recv"`；另起 goroutine 做昵称解析 + 打印，**绝不阻塞收包线程**。

`runEngineLoop` 实现**断线自动重连 + cookie 失效自愈**：每轮先 `ProbeCookie`，失效则 `relogin`，重连采用**指数退避**（2s→…→60s 上限）。

```go
for {
    if p := login.ProbeCookie(...); p.Expired { relogin(...); continue }
    conn, err := eng.Connect()
    if err != nil { sleep(backoff); backoff *= 2; continue }
    backoff = 2 * time.Second
    reason := eng.RunSession(conn, deliver, nil)  // 阻塞直到断开
    gw.EmitDisconnect(reason)
}
```
