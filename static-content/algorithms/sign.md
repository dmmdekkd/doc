---
title: 签名 sign
description: SHA256 + xor5 + msToken
---
## 签名 `sign`（`internal/sign/sign.go`）

电脑版 passport web 签名，`1:1` 转译自 JS 并对真机 HAR 逐字节验证。

```go
// sign = sha256( 排序后前10个query "k=v&..." + "&" + 排序后body "k=v&..." + "&app_key=" + AppKey )
// qs   = xor5( 排序后前10个参数名 join(",") )
// xor5 = 逐 UTF-8 字节 ^ 0x05 → 两位十六进制（即 code_encrypt）
func SignParams(query, body map[string]string) (signHex, qs string) {
    tStr, keys := sortedKV(query, 10)   // 参数名排序，取前 10
    eStr, _   := sortedKV(body, -1)
    h := tStr + "&" + eStr + "&app_key=" + AppKey  // AppKey="3c452fb664e3de0e936108429a0bc697"
    return hex.EncodeToString(sha256.Sum256([]byte(h))[:]), Xor5(strings.Join(keys, ","))
}
```

- **`sortedKV`**：key 字典序排序，`limit=10` 只取前 10 个（query），body 全取；拼成 `k=v&k=v`。
- **`Xor5`/`CodeEncrypt`**：手写 UTF-8 编码（1/2/3 字节，>0xffff 跳过，与 JS 一致），**每个字节 `^ 5`**，结果按 `%02x` 小写十六进制输出。手机号、短信验证码都用它加密。
- **`MsToken`**：`n` 位随机 base64url 串（字母表 `A-Za-z0-9-_`），默认 128 位。
