# `internal/login/helpers.go`

> package `login` &nbsp;·&nbsp; 37 行 &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## Imports

- `strconv`

## Functions

### `jstr`  <span class=lineno>L5</span>

```go
func jstr(v any) string
```

### `jmap`  <span class=lineno>L11</span>

```go
func jmap(v any) map[string]any
```

### `jnumStr`  <span class=lineno>L17</span>

```go
func jnumStr(v any) string
```

### `jint`  <span class=lineno>L28</span>

```go
func jint(v any) int
```


## Source (完整源码)
<details><summary>展开 — 与仓库版本逐字节一致</summary>

```go
package login

import "strconv"

func jstr(v any) string {
	if s, ok := v.(string); ok {
		return s
	}
	return ""
}
func jmap(v any) map[string]any {
	if m, ok := v.(map[string]any); ok {
		return m
	}
	return nil
}
func jnumStr(v any) string {
	switch x := v.(type) {
	case string:
		return x
	case float64:
		return strconv.FormatInt(int64(x), 10)
	case int64:
		return strconv.FormatInt(x, 10)
	}
	return ""
}
func jint(v any) int {
	switch x := v.(type) {
	case float64:
		return int(x)
	case string:
		n, _ := strconv.Atoi(x)
		return n
	}
	return 0
}
```
</details>
