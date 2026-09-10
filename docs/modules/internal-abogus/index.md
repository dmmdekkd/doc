# abogus — a_bogus

> package `abogus` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`abogus.go`](./abogus-go.md) — 6 个声明
- [`abogus_test.go`](./abogus_test-go.md) — 3 个声明
- [`hash.go`](./hash-go.md) — 12 个声明
- [`hash_test.go`](./hash_test-go.md) — 2 个声明

## 本包 API 速览


### `abogus.go`

- `type ctx` — L11  : ctx 承载可注入的时间与随机（便于对拍 JS）。
- `func encryptionUa` — L18  : ---- base64 变体 ----
- `func abArr256` — L44  : ---- RC4 变体 ----
- `func uaArr256` — L58
- `func garble` — L72
- `func uaGarbledCharacters` — L87

### `abogus_test.go`

- `func lcgRand` — L6  : Park-Miller LCG，与对拍用的 JS 补丁一致。
- `func TestABogusVsJS` — L14
- `func TestABogusProd` — L23

### `hash.go`

- `func ctRotl` — L6  : ctRotl 循环左移 32 位（JS: (e&lt;&lt;t | e&gt;&gt;&gt;32-t) &gt;&gt;&gt; 0）。
- `func stConst` — L14
- `func ktFF` — L21
- `func xtGG` — L28
- `type sm3reg` — L36  : sm3reg 对应 JS 里的 reg 对象。
- `func newReg` — L42
- `func (sm3reg) compress` — L48
- `func (sm3reg) write` — L87
- `func (sm3reg) fill` — L114
- `func getArr` — L134  : getArr 自定义 SM3：输入字符码数组，返回 32 字节（字符码数组）。
- `func codesOf` — L156  : codesOf 字符串 → 字符码数组（UTF-8 字节，对应 JS write 的 encodeURIComponent 口径）。
- `func getArrStr` — L165

### `hash_test.go`

- `func codesToStr` — L9
- `func TestGetArr` — L17