---
title: 发送消息流程
description: HTTP / WS 双通道、protobuf 外壳、撤回/表情/回复、媒体上传
---
## 发送消息流程（HTTP / WS 双通道）

发送由 `dispatchSend` 统一入口，根据 `bot.json` 的 `send_channel` 分流：

```go
func (c *Client) dispatchSend(convID string, shortID uint64, contentJSON string, msgType int) (SendResult, error) {
    if strings.EqualFold(c.SendChannel, "ws") { return c.sendViaWS(...) }  // 安卓 frontier WS
    return c.sendIMAPI(...)                                                // 默认 HTTP imapi
}
```

**为什么两个通道？** HTTP 通道（`douyin_pc` web_sdk）在**群聊场景常被风控拒**（返回 `status_code 7523`），此时切到 `ws` 用**安卓端身份**绕开。`content / conv_type / msg_type` 两套完全一致，仅传输外壳不同。

会话类型（`field100.f2`）：`1=单聊`、`2=群聊`；消息类型（`field100.f6`）：`文本=7`、`表情=5`、`图片=27`、`视频=30`。`resolveConvSend` 由 convID 形态决定：`纯数字=群聊`、`0:1:=私信`。

### 1. 默认通道：HTTP（`httpsend.go`，imapi）

端点 `https://imapi.douyin.com/v1/message/send`，**body 是 `application/x-protobuf`**（与 WS 帧同构、去掉 frontier 外壳），无 .proto，用裸 proto 编码器按 HAR 硬拼。

**通用外壳 `buildEnvelope`（cmd + f8 内层 + 浏览器指纹 KV）**：

```go
body := concat(
    encodeFieldVarint(1, uint64(cmd)),   // cmd=100 发消息 / 702 撤回
    encodeFieldVarint(2, uint64(nextSeq())),
    encodeLenDelimS(3, webSDKVersion),   // "0.1.8"
    ...
    encodeLenDelim(8, encodeLenDelim(innerField, inner)),  // f8 = 内层
    encodeLenDelimS(9, dev),             // device_id(session_did)
    ...                                  // f15 = 浏览器指纹 KV
)
```

**发消息 body（`buildIMAPIBody`，cmd=100）** 的 `field100`：

| field | 含义 |
|---|---|
| f1 | conv_id（`0:1:x:y` 或群号）|
| f2 | conv_type（1 单聊 / 2 群聊）|
| f3 | conversation_short_id |
| f4 | content（JSON 字符串）|
| f5 | ext KV：`s:client_message_id`、`s:stime`、`s:mentioned_users` |
| f6 | msg_type（7/5/27/30）|
| f8 | client_message_id |

`content` 形态：

- **文本** `imapiTextContent{aweType:700, type:0, richTextInfos:[], text}`
- **图片** `imapiImageContent{resource_url:{oid,skey,data_size,md5}, cover_w/h, from_gallery:1, aweType:2702}`
- **表情** `imapiEmojiContent{display_name,..., url:{uri,url_list}, aweType:507}`
- **回复** `imapiReplyContent{refmsg_type:7, content, refmsg_uid, refmsg_sec_uid, nickname, refmsg_content(嵌套 textContent), version:1}`

`postIMAPIRaw` 设置 `Content-Type: application/x-protobuf`、`User-Agent: douyinim/1.1.33`、`Cookie`、`Referer: https://imdesktop.douyin.com` 后 POST；解析回执：`f3==0` 成功，`f6→f100→f1` 取 `server_msg_id`。

### 2. 绕风控通道：WS（`wssend.go`，安卓 frontier）

`sendViaWS`：建一个新 WS 连接 → 组 cmd100 帧 → `conn.Send(payload)` → `drainSendAck` 读回执（4s 超时）。

**帧是三层嵌套 protobuf**：

```
外层(frontier) : f1=seq f2=ts f3=5 f4=1 f5=KV{cmd100...} f6/f7="pb" f8=inner
内层(cmd100)   : f1=100 f2=seq f3=sdkver f7=build f8=msgWrapper f9=uid f11="android"
                 f15=KV.. f21/f22=biz/access
msgWrapper     : f100 = field100{ f1 conv_id, f2 conv_type, f3 short, f4 content,
                                 f5 ext..., f6 msg_type, [f7 ticket], f8 cmid, f12 ext }
```

`wsAdaptContent`：群聊把文本 content 换成**安卓 ch1（`douyin_main`）shape**；图片 / 表情 / 视频暂复用。

**回执解析 `matchSendAck`**：沿 `8→6→500→5[*]` 找 KV，匹配 `s:client_message_id==本条` → `f3=server_msg_id`；风控看 `s:vcd_shark_decision=="BLOCK"` 或 `im_callback_status_code ∈ {8101,8610,10502}` → `blocked`。

### 3. 撤回 / 表情 / 回复（`imactions.go`）

三者都复用 `buildEnvelope`，只改 cmd 号与内层：

- **撤回** `Recall`：cmd=`702`，内层 `f702{conv_id, short_id, 3:1, server_msg_id}`，判 `f3==0`。
- **表情** `SendEmojiResult`：走 `dispatchSend(..., msgTypeEmoji)`，content `aweType=507`。
- **回复** `SendReplyResult`：content 带 `refmsg_*`，`refmsg_content` 嵌套 textContent，`refmsg_type=7`。

### 4. 媒体上传

- **图片** `upload.go`：先 `upload_image` 拿 `ImageAsset{oid,skey,data_size,md5,cover_w,cover_h}`，再随发图 content 发出；上传走 **SigV4 → TOS**。
- **视频** `video.go` + `videoplay.go`：视频**分片上传**；播放用 `tkey` 换 `batch_play_info` 得 CDN 地址（`get_video_url`），流仍是 CENC 密文，需解密（见[媒体加解密](/algorithms/media-crypto)）。
