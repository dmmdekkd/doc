---
title: Protobuf 编解码
description: 裸 / 宽松 protobuf 的编码、启发式解码与字段路径查询
---
## Protobuf 编解码（裸 / 宽松）

由于服务端无公开 `.proto`，项目实现**宽松 / 猜测式**编解码器，`Type ∈ {varint, string, message, bytes}`。源码：`internal/engine/proto.go`。

### 编码

标准 varint + tag（`fieldNum << 3 | wireType`）：`encodeFieldVarint` / `encodeLenDelim` / `encodeKvPair`（重复 KV 字段 `f1=key, f2=value`）。这是收发两侧组帧的基础。

### 解码 `decodeProtobuf`

逐字节读 tag → 按 wireType（0=varint, 2=length-delimited, 1/5=fixed）解析。对 length-delimited 字段做**启发式判别**：

```go
looksJson   := 以 '{' 或 '[' 开头
looksToken  := "MS4..." / http:// / https:// / 纯数字 / hex token(uuid/md5)
if looksJson || looksToken {
    → 当作 string
} else {
    → 递归当作嵌套 message；递归失败且是合法 UTF-8 → string；否则 → bytes(base64)
}
```

关键细节：`tryUtf8` 拒绝含控制字符或非法 UTF-8 的字节；`looksHexToken` 防止 uuid / md5 被误当嵌套 message（`depth<8` 限制递归）。

### 辅助

- `DecodeToTree`：把原始帧转 `{f,t,v}` 树（bytes→base64），供 `/oriws` 调试。
- `searchPath(fields, [8,6,500,5,3])`：沿字段号路径提取值——**从复杂帧里抠 short_id / server_msg_id 的通用手段**。
