# login — 登录

> package `login` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`client.go`](./client-go.md) — 3 个声明
- [`device.go`](./device-go.md) — 1 个声明
- [`fingerprint.go`](./fingerprint-go.md) — 1 个声明
- [`helpers.go`](./helpers-go.md) — 4 个声明
- [`probe.go`](./probe-go.md) — 2 个声明
- [`qrlogin.go`](./qrlogin-go.md) — 6 个声明
- [`smslogin.go`](./smslogin-go.md) — 3 个声明
- [`smslogin_test.go`](./smslogin_test-go.md) — 4 个声明

## 本包 API 速览


### `client.go`

- `const aid` — L18
- `const defaultUA` — L19
- `func nowMs` — L21

### `device.go`

- `func GenDeviceID` — L9  : GenDeviceID 生成随机 device_id：324 开头 + 7 位随机数字（共 10 位）。

### `fingerprint.go`

- `func buildFingerprint` — L11  : buildFingerprint 生成 account_sdk_source_info（xor5(JSON)）。

### `helpers.go`

- `func jstr` — L5
- `func jmap` — L11
- `func jnumStr` — L17
- `func jint` — L28

### `probe.go`

- `type ProbeResult` — L4  : ProbeResult cookie 探测结果。
- `func ProbeCookie` — L13  : ProbeCookie GET /passport/account/info/v2/：user_id&gt;0 &amp;&amp; error_code==0 为活。

### `qrlogin.go`

- `const nextURL` — L12
- `type LoginResult` — L15  : LoginResult 登录结果。
- `type Hooks` — L23  : Hooks 登录过程回调。
- `func QRLogin` — L33  : QRLogin 扫码登录。deviceID 为空则新生成。
- `func pickBizParams` — L125
- `func (Client) doMfa` — L136

### `smslogin.go`

- `func SMSLogin` — L16  : SMSLogin 手机号 + 短信验证码登录。deviceID 为空则新生成。
- `func formatMobile` — L92  : formatMobile 归一成 "+86 &lt;号码&gt;"（服务端要求国家码与号码间有一个空格）。
- `func errDesc` — L109  : errDesc 从 passport 响应里抽出可读错误信息。

### `smslogin_test.go`

- `func xor5Decode` — L11  : xor5Decode 是 sign.CodeEncrypt 的逆：hex 解码后逐字节 XOR 5。
- `func TestFormatMobile` — L20
- `func TestSMSTypeEncrypt` — L40  : send_code 的 type=24 场景码，加密后应为 3731（与真机 HAR 一致）。
- `func TestSMSMobileCodeEncryptReversible` — L47  : mobile/code 用 code_encrypt(Xor5+hex) 加密，必须可逆回原文（明文格式含 "+86 " 前缀+空格）。