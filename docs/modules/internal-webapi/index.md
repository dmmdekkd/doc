# webapi — 昵称解析

> package `webapi` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`im.go`](./im-go.md) — 7 个声明

## 本包 API 速览


### `im.go`

- `var webHTTP` — L18
- `const ua` — L20
- `type User` — L23  : User 解析出的用户。
- `func encodeKV` — L25
- `func FetchUserInfo` — L34  : FetchUserInfo 直接请求 im/user/info（multipart sec_user_ids）。失败返回空表。
- `func uidStr` — L95
- `func ResolveUsers` — L106  : ResolveUsers 带 sqlite 缓存：先查缓存，缺的才请求并写回。