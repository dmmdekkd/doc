# media — 媒体加解密

> package `media` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`cenc.go`](./cenc-go.md) — 2 个声明
- [`cenc_test.go`](./cenc_test-go.md) — 3 个声明
- [`image.go`](./image-go.md) — 6 个声明
- [`image_test.go`](./image_test-go.md) — 3 个声明
- [`imageserver.go`](./imageserver-go.md) — 6 个声明
- [`mp4cenc.go`](./mp4cenc-go.md) — 2 个声明
- [`mp4cenc_test.go`](./mp4cenc_test-go.md) — 6 个声明
- [`videoserver.go`](./videoserver-go.md) — 5 个声明
- [`videoserver_test.go`](./videoserver_test-go.md) — 4 个声明

## 本包 API 速览


### `cenc.go`

- `type Subsample` — L16  : CENC (cenc-aes-ctr) 视频解密核心，逆自电脑版 player.js 的 decoderAESCTRData。
- `func cencDecryptSample` — L22  : cencDecryptSample 解一个 sample。subs 为空表示整 sample 加密。返回同长度的明文。

### `cenc_test.go`

- `func TestCENCSampleRoundTrip` — L11  : CENC 子样本 AES-CTR 往返：CTR 对称，同一套 splice 逻辑跑两遍应还原；明文(clear)段不该变。
- `func TestCENCWholeSampleRoundTrip` — L41  : 无子样本：整段加密的往返。
- `func TestCENCCounterContinuity` — L57  : counter 跨子样本连续（不是每段重置）：把两段 protected 当成一整条解，等价于连续 CTR。

### `image.go`

- `type ImageResource` — L15  : ImageResource 对应消息里的 resource_url。
- `func DecryptImage` — L25  : DecryptImage 解密图片容器。
- `func (ImageResource) PickURL` — L47  : PickURL 挑一个可用图片 url（原图优先）。
- `func SniffExt` — L57  : SniffExt 从解出的字节推断扩展名。
- `func sniffMime` — L72
- `func FetchAndDecrypt` — L88  : FetchAndDecrypt 下载 url、用 skey 解密，返回图片字节。

### `image_test.go`

- `func TestDecryptImageRoundTrip` — L12
- `func TestImageLink` — L36
- `func TestAllowedImageHost` — L50

### `imageserver.go`

- `var proxyBase, proxyMu` — L14  : 图片解密代理：不自己监听端口，挂到网关的 HTTP mux 上共用同一端口。
- `var allowedImageHosts` — L20  : 只允许解密图床域名，堵住"取任意 URL"的 SSRF。
- `func allowedImageHost` — L25
- `func SetProxyBase` — L40  : SetProxyBase 网关启动时告知自己的地址，图片链接据此拼。
- `func ImageHandler` — L47  : ImageHandler /img 处理器，挂到网关 mux 上。免鉴权（&lt;img&gt; 带不了 header）+ 域名白名单兜底。
- `func ImageLink` — L69  : ImageLink 拼本地解密代理链接；未设 base（网关没起）时返回原始 url。

### `mp4cenc.go`

- `type mp4box` — L12  : CENC MP4 解密：定位每个 sample、AES-128-CTR 解密其 protected 段、再把加密盒子改名让文件"变明文"可播。
- `func u16` — L19

### `mp4cenc_test.go`

- `func TestDecryptVideoPayload` — L14  : 用真机加密样本 har/payload.mp4 跑完整 CENC 解密管线，再用 ffprobe/ffmpeg 验证输出可解码。
- `func assertMdatIntact` — L54  : mdat 内容区不参与改名，且 CTR 等长；这里确认 mdat 盒子头位置与大小没动。
- `func assertFirstVideoSampleNAL` — L68  : 走一遍首视频样本的 4 字节长度前缀链，累加应正好等于样本大小。
- `func firstVideoSample` — L89  : 从解密后的 MP4 里取视频轨第一个样本的绝对偏移与大小（复用生产解析器）。
- `func ffprobeCheck` — L122
- `func ffmpegDecodeCheck` — L141

### `videoserver.go`

- `const maxVideoBytes` — L15  : 视频解密：CENC 视频流本身仍是密文，key = 消息里的 video.skey。
- `var videoHTTP` — L17
- `func FetchVideoAndDecrypt` — L20  : FetchVideoAndDecrypt 下载 CENC MP4（main 失败回退 backup）并用 skey 解密成可播 MP4。
- `func fetchVideo` — L31
- `func VideoLink` — L51  : VideoLink 拼本地视频解密代理链接；未设 base（网关没起）时返回空串。

### `videoserver_test.go`

- `func TestFetchVideoAndDecrypt` — L14  : 用真机加密样本走完整代理下载路径：TLS 假 CDN 提供 CENC MP4 → FetchVideoAndDecrypt → 明文可播 MP4。
- `func TestFetchVideoBackupFallback` — L47  : backup 回退：main 报错时应改用 backup。
- `func TestFetchVideoRejectsNonHTTPS` — L71
- `func TestVideoLink` — L77