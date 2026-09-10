# qr — 二维码

> package `qr` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`qr.go`](./qr-go.md) — 7 个声明
- [`qr_test.go`](./qr_test-go.md) — 4 个声明

## 本包 API 速览


### `qr.go`

- `func DecodeQRPng` — L25  : DecodeQRPng 解出二维码内容（URL/字符串）。
- `func RenderTerminal` — L45  : RenderTerminal 内容 → 紧凑终端二维码（ECC=L）。默认半块（实心、可扫），GOBOT_QR=braille 换盲文。
- `func darkFn` — L57  : darkFn 返回一个判定：给定含静默区坐标是否为暗模块（越界/静默区=亮）。
- `func renderHalf` — L70  : renderHalf 半块渲染：1 模块宽 × 2 模块高/字符，暗=实心。模块正方、实心，最稳。
- `func renderBraille` — L101  : renderBraille 盲文点阵：2 模块宽 × 4 模块高/字符（U+2800 起）。模块正方、尺寸最小。
- `func RenderPNG` — L145  : RenderPNG 把内容编码成 PNG 图片字节（含静默区，每模块 8px），用于存本地直接扫图。
- `func PngToTerminalQR` — L155  : PngToTerminalQR PNG(base64) → 终端二维码串。

### `qr_test.go`

- `func renderMatrixImage` — L15  : renderMatrixImage 把二维码矩阵画成放大的黑白图（暗模块=黑，含 4 模块静默区）。
- `func goqrRecognize` — L38
- `func TestDecodeRealDouyinQR` — L50
- `func TestRenderMatrixScannable` — L98  : TestRenderMatrixScannable 校验渲染用的模块矩阵极性正确：