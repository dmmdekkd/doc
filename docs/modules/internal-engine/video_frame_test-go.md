# `internal/engine/video_frame_test.go`

> package `engine` &nbsp;·&nbsp; 49 行 &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## Imports

- `os`
- `testing`

## Functions

### `TestExtractVideoFrame`  <span class=lineno>L9</span>

用真机完整视频帧跑一遍收包路径：帧字节 → decodeTop → collectChat → parseChatJsonItem → 视频条目。

```go
func TestExtractVideoFrame(t *testing.T)
```


## Source (完整源码)
<details><summary>展开 — 与仓库版本逐字节一致</summary>

```go
package engine

import (
	"os"
	"testing"
)

// 用真机完整视频帧跑一遍收包路径：帧字节 → decodeTop → collectChat → parseChatJsonItem → 视频条目。
func TestExtractVideoFrame(t *testing.T) {
	raw, err := os.ReadFile("testdata/video_frame.bin")
	if err != nil {
		t.Skip("无 video_frame.bin")
	}
	c := New("", "3916922778814715", "3916922778814715")
	items := c.extractChatItems(raw, "3916922778814715")

	var vid *ImVideo
	var text string
	for _, it := range items {
		if it.video != nil {
			vid, text = it.video, it.text
		}
	}
	if vid == nil {
		t.Fatalf("未从真实帧解出视频（items=%d）", len(items))
	}
	if vid.Tkey != "tos-cn-o-00061/e84893a8619c44cdb98e7731b0760406" {
		t.Fatalf("tkey 不对: %s", vid.Tkey)
	}
	if vid.Skey != "4bedadda440db36856379936270ec6cc" || vid.Md5 != "d7f7125ec843a4dbe0737d6cdb1b79f8" {
		t.Fatalf("skey/md5 不对: %+v", vid)
	}
	if vid.Width != 720 || vid.Height != 1280 {
		t.Fatalf("尺寸不对: %dx%d", vid.Width, vid.Height)
	}
	if len(vid.CheckPics) != 1 || vid.CheckPics[0] != "tos-cn-o-0812/oM1qedv2ADAzAGpHAQL4RCIGfeCXlfQICLIJFg" {
		t.Fatalf("check_pics 不对: %v", vid.CheckPics)
	}
	if vid.Poster == nil || vid.Poster.Skey != "fc923349465aa2d0fcf5ff1e0c1ad84dd2ca0ebf869c61fd5986284b93f807cd" ||
		vid.Poster.Oid != "tos-cn-o-00061/4477c8b7b66f412192a0905e42476f50" {
		t.Fatalf("poster 不对: %+v", vid.Poster)
	}
	if len(vid.Poster.OriginURLList) != 1 || len(vid.Poster.MediumURLList) != 1 {
		t.Fatalf("poster url_list 未解全: %+v", vid.Poster)
	}
	if text != "[视频]" {
		t.Fatalf("视频占位文本不对: %q", text)
	}
}
```
</details>
