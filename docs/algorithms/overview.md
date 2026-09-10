---
title: 算法总览
description: sign / a_bogus / 媒体加解密 一览
---
## 算法总览

| 算法 | 位置 | 用途 |
|---|---|---|
| `sign` / `qs` / `xor5` / `msToken` | `internal/sign` | 电脑版 passport web 请求签名 |
| `a_bogus` | `internal/abogus` | web 端反爬签名（SM3 + RC4 变体 + base64 变体）|
| 图片 AES-256-GCM | `internal/media/image.go` | 图片解密 |
| 视频 CENC-AES-128-CTR | `internal/media/cenc.go` (+ `mp4cenc.go`) | 视频解密 |

详见各小节：[sign](/algorithms/sign)、[a_bogus](/algorithms/abogus)、[媒体加解密](/algorithms/media-crypto)。
