# `internal/login/smslogin_test.go`

> package `login` &nbsp;·&nbsp; 58 行 &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## Imports

- `encoding/hex`
- `testing`
- `gobot/internal/sign`

## Functions

### `xor5Decode`  <span class=lineno>L11</span>

xor5Decode 是 sign.CodeEncrypt 的逆：hex 解码后逐字节 XOR 5。

```go
func xor5Decode(h string) string
```

### `TestFormatMobile`  <span class=lineno>L20</span>

```go
func TestFormatMobile(t *testing.T)
```

### `TestSMSTypeEncrypt`  <span class=lineno>L40</span>

send_code 的 type=24 场景码，加密后应为 3731（与真机 HAR 一致）。

```go
func TestSMSTypeEncrypt(t *testing.T)
```

### `TestSMSMobileCodeEncryptReversible`  <span class=lineno>L47</span>

mobile/code 用 code_encrypt(Xor5+hex) 加密，必须可逆回原文（明文格式含 "+86 " 前缀+空格）。

```go
func TestSMSMobileCodeEncryptReversible(t *testing.T)
```


## Source (完整源码)
<details><summary>展开 — 与仓库版本逐字节一致</summary>

```go
package login

import (
	"encoding/hex"
	"testing"

	"gobot/internal/sign"
)

// xor5Decode 是 sign.CodeEncrypt 的逆：hex 解码后逐字节 XOR 5。
func xor5Decode(h string) string {
	b, _ := hex.DecodeString(h)
	out := make([]byte, len(b))
	for i, c := range b {
		out[i] = c ^ 5
	}
	return string(out)
}

func TestFormatMobile(t *testing.T) {
	cases := [][2]string{
		{"13800138000", "+86 13800138000"},
		{"+8613800138000", "+86 13800138000"},
		{"+86 13800138000", "+86 13800138000"},
		{"138-0013-8000", "+86 13800138000"},
		{"8613800138000", "+86 13800138000"},
		{"  13800138000 ", "+86 13800138000"},
		{"(138)0013-8000", "+86 13800138000"},
		{"", ""},
		{"+13800138000", "+13800138000"}, // 其它国家码原样
	}
	for _, c := range cases {
		if got := formatMobile(c[0]); got != c[1] {
			t.Errorf("formatMobile(%q)=%q 期望 %q", c[0], got, c[1])
		}
	}
}

// send_code 的 type=24 场景码，加密后应为 3731（与真机 HAR 一致）。
func TestSMSTypeEncrypt(t *testing.T) {
	if got := sign.CodeEncrypt("24"); got != "3731" {
		t.Fatalf("type 加密=%s 期望 3731", got)
	}
}

// mobile/code 用 code_encrypt(Xor5+hex) 加密，必须可逆回原文（明文格式含 "+86 " 前缀+空格）。
func TestSMSMobileCodeEncryptReversible(t *testing.T) {
	m := formatMobile("13800138000")
	if m != "+86 13800138000" {
		t.Fatalf("formatMobile=%q", m)
	}
	if back := xor5Decode(sign.CodeEncrypt(m)); back != m {
		t.Fatalf("mobile 加密不可逆: 得到 %q", back)
	}
	if back := xor5Decode(sign.CodeEncrypt("123456")); back != "123456" {
		t.Fatalf("code 加密不可逆: 得到 %q", back)
	}
}
```
</details>
