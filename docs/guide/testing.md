---
title: 自检与测试
description: selftest / smoke / go test 与调试技巧
---
## 自检与联机测试

```bash
jumpbyte-bot --selftest   # 自检算法 (sign / a_bogus / protobuf / 媒体解密向量)
jumpbyte-bot --smoke      # 给自己发一条测试消息，验证收发联机
```

项目每个包都配套 `_test.go`（见[源码模块](/modules/internal-abogus/index)），覆盖：

- `sign`、`abogus`：向量比对（已知输入输出）
- `engine`：protobuf 编解码往返、WS / HTTP 发送帧构造、群帧 / 视频帧解析
- `media`：图片 AES-GCM、CENC-AES-128-CTR、MP4 box 解析
- `gateway`：HTTP 路由与 WS 事件推送

```bash
go test ./...
```

### 调试技巧

- 原始 protobuf 帧：`ws://HOST:PORT/oriws?access_token=TOKEN`，每帧下推 `{type,time,len,b64,fields}`（`fields` 即 `DecodeToTree` 输出），对照抓包分析未支持的消息类型。
- 抓包：`HTTP_PROXY` / `HTTPS_PROXY` 环境变量被 `applyProxy` 尊重，可指向 mitmproxy。
- `--smoke` 给自己发消息，验证「收 WS → 解析 → 发回」整条链路。
