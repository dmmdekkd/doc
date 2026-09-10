# config — 配置

> package `config` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`bot.go`](./bot-go.md) — 2 个声明
- [`config.go`](./config-go.md) — 3 个声明

## 本包 API 速览


### `bot.go`

- `type BotConfig` — L12  : BotConfig 网关配置（bot.json）。token 首次启动自动生成写回。
- `func BotConfigPath` — L22  : BotConfigPath bot.json 路径。

### `config.go`

- `var Dir` — L12  : Dir cookie.json / bot.db 所在目录，默认当前工作目录（分发时就近放）。
- `type Account` — L15  : Account 单账号配置。
- `func CookiePath` — L29  : CookiePath cookie.json 路径。