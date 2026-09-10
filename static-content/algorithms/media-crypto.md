---
title: 媒体加解密
description: 图片 AES-256-GCM 与视频 CENC-AES-128-CTR
---
## 媒体加解密（`internal/media/`）

### 图片 AES-256-GCM（`image.go`）

下载回来的图片是加密容器 `IV(12) ‖ 密文 ‖ GCM_tag(16)`，`key = skey`（64 hex → 32 字节）。

```go
func DecryptImage(encrypted []byte, skeyHex string) ([]byte, error) {
    key, _ := hex.DecodeString(skeyHex)   // 必须 32 字节
    iv   := encrypted[:12]
    rest := encrypted[12:]                 // 密文+tag
    block, _ := aes.NewCipher(key)
    gcm, _  := cipher.NewGCMWithNonceSize(block, 12)
    return gcm.Open(nil, iv, rest, nil)    // AEAD 解密+验签
}
```

附带 `SniffExt` 按魔数识别 `WEBP/JPG/PNG/HEIC`；`FetchAndDecrypt` 一站式下载+解密；`ImageLink` 暴露本地代理链接。

### 视频 CENC-AES-128-CTR（`cenc.go`）

`key = video.skey` 原始字节（16 字节，AES-128），`iv = senc InitializationVector`（8 或 16 字节，补零到 16）。

```go
// 每个 sample: 把所有 protected 子样本拼成一条, 单条 AES-128-CTR 解密, 再按 {clear,protected} 拼回
// counter 在整条 protected 流上连续递增(跨子样本不重置)
ctr := cipher.NewCTR(block, counter)
if len(subs) == 0 { ctr.XORKeyStream(out, data) } else {
    for _, s := range subs { protected = append(protected, data[pos+s.Clear : pos+s.Clear+s.Protected]...) }
    ctr.XORKeyStream(dec, protected)
    // 交错拼回: clear 原样 + dec 段
}
```

`mp4cenc.go` 解析 MP4 的 `tenc`/`senc` box，抽出每个 sample 的 IV 与 subsample 表，喂给上述核心。`Videoserver`/`Imageserver` 是本地 HTTP 代理，把解密后明文以 `Range` 支持方式吐给播放器。
