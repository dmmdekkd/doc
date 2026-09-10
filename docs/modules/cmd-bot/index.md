# cmd/bot — 入口

> package `main` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`main.go`](./main-go.md) — 14 个声明

## 本包 API 速览


### `main.go`

- `func main` — L36
- `func runSmoke` — L52  : runSmoke 向自己发一条带 nonce 的消息，若在收包连接上看到它回显，即证明发帧被服务端接收 + 收包解析可用。
- `func contains` — L93
- `func terminalHooks` — L102
- `func saveQRPng` — L135  : saveQRPng 把二维码存一份本地 PNG（优先用权威 URL 自己编码，否则退回服务端 PNG）。
- `func loginAndSave` — L160  : loginAndSave phone 非空走短信验证码登录，否则扫码登录；结果落盘（保留 phone 供下次自愈）。
- `func runLogin` — L182
- `func runCli` — L200
- `func onIncoming` — L299  : onIncoming 打印一条收到的消息（图片透出本地代理链接，昵称走缓存解析）。
- `func runEngineLoop` — L316  : runEngineLoop 连接 → 收包 → 断线自动重连（带指数退避 + cookie 失效自愈）。
- `func relogin` — L366  : relogin cookie 失效时重新登录（有 phone 走短信，否则扫码），原地更新 acc + eng（网关持有 acc 指针，同步生效）。
- `func capDur` — L377
- `func stdinSender` — L385  : stdinSender 从标准输入读  @&lt;conv_id&gt; &lt;文本&gt;  并发送。
- `func runSelfTest` — L411