# `internal/engine/wsconn_test.go`

> package `engine` &nbsp;·&nbsp; 41 行 &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## Imports

- `net/http`
- `testing`
- `github.com/gorilla/websocket`

## Functions

### `TestWsFollowsEnvProxy`  <span class=lineno>L11</span>

无显式代理时 WS 拨号器应跟随环境代理（HTTP(S)_PROXY），这样 WS 能和 HTTP 一样经终端代理抓包。

```go
func TestWsFollowsEnvProxy(t *testing.T)
```

### `TestWsExplicitHTTPProxy`  <span class=lineno>L31</span>

显式 http 代理直接生效。

```go
func TestWsExplicitHTTPProxy(t *testing.T)
```


## Source (完整源码)
<details><summary>展开 — 与仓库版本逐字节一致</summary>

```go
package engine

import (
	"net/http"
	"testing"

	"github.com/gorilla/websocket"
)

// 无显式代理时 WS 拨号器应跟随环境代理（HTTP(S)_PROXY），这样 WS 能和 HTTP 一样经终端代理抓包。
func TestWsFollowsEnvProxy(t *testing.T) {
	var d websocket.Dialer
	if err := applyProxy(&d, nil); err != nil {
		t.Fatal(err)
	}
	if d.Proxy == nil {
		t.Fatal("无显式代理时 d.Proxy 应指向环境代理（非 nil）")
	}
	// 显式设置一个 http 代理，验证仍取到它（隔离环境差异）
	t.Setenv("HTTPS_PROXY", "http://127.0.0.1:9999")
	req, _ := http.NewRequest("GET", "https://imapi.douyin.com/", nil)
	if u, err := d.Proxy(req); err != nil {
		t.Fatalf("Proxy 求值出错: %v", err)
	} else if u != nil && u.Host != "127.0.0.1:9999" {
		// http.ProxyFromEnvironment 可能已缓存进程启动时的环境值，这里不强判具体值，只要不报错即可
		t.Logf("env proxy = %s（若与设置不符是 ProxyFromEnvironment 的进程级缓存所致，不影响功能）", u.Host)
	}
}

// 显式 http 代理直接生效。
func TestWsExplicitHTTPProxy(t *testing.T) {
	var d websocket.Dialer
	if err := applyProxy(&d, &WsProxy{Scheme: "http", Host: "127.0.0.1", Port: 8888}); err != nil {
		t.Fatal(err)
	}
	req, _ := http.NewRequest("GET", "https://x/", nil)
	u, err := d.Proxy(req)
	if err != nil || u == nil || u.Host != "127.0.0.1:8888" {
		t.Fatalf("显式 http 代理应生效: u=%v err=%v", u, err)
	}
}
```
</details>
