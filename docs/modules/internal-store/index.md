# store — 缓存

> package `store` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`cache.go`](./cache-go.md) — 5 个声明

## 本包 API 速览


### `cache.go`

- `var db, once, oerr` — L15
- `func open` — L21
- `type CachedUser` — L41  : CachedUser 缓存的用户资料。
- `func GetCachedUsers` — L47  : GetCachedUsers 批量取缓存。
- `func PutUsers` — L77  : PutUsers 批量写入/更新。