# sign — 签名

> package `sign` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`sign.go`](./sign-go.md) — 3 个声明
- [`sign_test.go`](./sign_test-go.md) — 3 个声明

## 本包 API 速览


### `sign.go`

- `const AppKey` — L17  : AppKey 取自客户端 renderer（appKey:"3c452fb6..."）。
- `func Xor5` — L21  : Xor5 = code_encrypt：UTF-8 编码后每字节 ^5，两位十六进制。
- `func CodeEncrypt` — L47  : CodeEncrypt 别名（短信验证码加密）。

### `sign_test.go`

- `func TestXor5` — L6  : 期望值取自已对真机 HAR 验证过的 TS 实现（同一输入）。
- `func TestSignParams` — L12
- `func TestMsToken` — L38