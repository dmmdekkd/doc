# gateway — 网关

> package `gateway` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`gateway.go`](./gateway-go.md) — 16 个声明
- [`gateway_test.go`](./gateway_test-go.md) — 23 个声明

## 本包 API 速览


### `gateway.go`

- `const protocolVersion` — L32
- `const maxBody` — L33
- `type accountStatus` — L35
- `type wsClient` — L46  : wsClient 每个 WS 连接一个带缓冲的发送队列 + 独立写 goroutine。
- `func newWsClient` — L53
- `func (wsClient) writeLoop` — L62
- `func (wsClient) push` — L86  : push 非阻塞入队；满了先丢最旧再塞，还满就放弃这条（不拖垮广播方）。
- `func (wsClient) close` — L101
- `type Sender` — L109  : Sender 发送能力（*engine.Client 实现；便于测试替身）。
- `type Gateway` — L122  : Gateway 单账号网关。
- `func New` — L140  : New 创建网关。
- `func (Gateway) handler` — L151  : handler 路由（Start 与测试共用）。
- `func (Gateway) Start` — L166  : Start 监听 host:port（后台）。
- `func (Gateway) Stop` — L178  : Stop 关闭 HTTP 服务并断开所有 WS 连接（优雅退出用）。
- `func (Gateway) linkAddr` — L193  : linkAddr 供图片链接用的地址：host 是 0.0.0.0/空时回落到 127.0.0.1。
- `func (Gateway) Addr` — L202  : Addr host:port，打印用。

### `gateway_test.go`

- `type fakeSender` — L20
- `func (fakeSender) SendTextEx` — L29
- `func (fakeSender) SendImageResult` — L34
- `func (fakeSender) UploadImage` — L39
- `func (fakeSender) SendEmojiResult` — L43
- `func (fakeSender) SendReplyResult` — L48
- `func (fakeSender) SendVideoResult` — L53
- `func (fakeSender) Recall` — L58
- `func (fakeSender) ListConversations` — L63
- `func (fakeSender) ResolveVideoURL` — L67
- `func newTestGW` — L78
- `func post` — L85
- `func TestHealthNoAuth` — L102
- `func TestAuth` — L122
- `func TestUnknownAndMethod` — L137
- `func TestSendTextValidationAndSuccess` — L151
- `func TestSendImage` — L176
- `func TestWebSocketHelloPongAndEvent` — L193
- `func TestOriWsRawFrame` — L226
- `func TestEmitSelf` — L259
- `func TestVideoProxyValidation` — L299  : /video 代理：缺参 400；tkey 换址失败 502。（下载+解密的正路在 media 包用真样本测。）
- `func TestGetVideoURLPlayLink` — L328  : get_video_url 给了 skey 时应回本地解密代理 play_url。
- `func TestWebSocketBadToken` — L350