# `internal/login/device.go`

> package `login` &nbsp;·&nbsp; 18 行 &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## Imports

- `crypto/rand`
- `strings`

## Functions

### `GenDeviceID`  <span class=lineno>L9</span>

GenDeviceID 生成随机 device_id：324 开头 + 7 位随机数字（共 10 位）。

```go
func GenDeviceID() string
```


## Source (完整源码)
<details><summary>展开 — 与仓库版本逐字节一致</summary>

```go
package login

import (
	"crypto/rand"
	"strings"
)

// GenDeviceID 生成随机 device_id：324 开头 + 7 位随机数字（共 10 位）。
func GenDeviceID() string {
	var sb strings.Builder
	sb.WriteString("324")
	b := make([]byte, 7)
	_, _ = rand.Read(b)
	for _, x := range b {
		sb.WriteByte('0' + x%10)
	}
	return sb.String()
}
```
</details>
