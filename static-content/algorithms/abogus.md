---
title: a_bogus
description: 自定义 SM3 + RC4 变体 + base64 变体
---
## a_bogus（`internal/abogus/`）

web 端反爬签名，三步：**自定义 SM3 哈希 → RC4 变体混淆 → 自定义 base64 变体编码**。`[]int` 全程承载「字符码数组」，避免编码走样（源自 `NewabComplete_1.0.1.20.js` 的 `1:1` 转译）。

### ① 自定义 SM3（`hash.go`）

完整实现 SM3 压缩函数：`ctRotl` 循环左移、`ktFF`（前 16 轮 `x^y^z`，后 48 轮 `(x&y)|(x&z)|(y&z)`）、`xtGG`、`sm3reg` 寄存器初值 `[1937774191, 1226093241, ...]`，`compress` 做消息扩展 `t[16..67]` + `t[n+68]=t[n]^t[n+4]`，64 轮置换，`write/fill` 处理分块与填充（append `0x80` + 长度）。输出 32 字节。

### ② RC4 变体（`abArr256` / `uaArr256` + `garble`）

- `abArr256`：S 盒初始化为 `255-i`，打乱时用**乘法递推** `prev=(prev*nums[i]+prev+211)%256`（标准 RC4 是 `i+j`），这是「变体」核心。
- `uaArr256(uaSalt)`：打乱系数用 `[0,1,uaSalt]` 三元素循环。
- `garble`：标准 RC4 PRGA 的变体——`n7=(S[i2]+old)&255`，输出 `input[i] ^ S[n7]`。

### ③ base64 变体（`encryptionUa` / `generate`）

- 自定义 64 字符表：`ckdp1h4ZKsUB80/Mfvw36XIgR25+WQAlEi7NLboqYTOPuzmFjJnryx9HVGDaStCe`（加密用）与 `Dkdpgh2ZmsQB80/MfvV36XI1R45-WUAlEixNLwoqYTOPuzKFjJnry79HbGcaStCe`（最终输出用），**下标映射 `&16515072>>18`、`&258048>>12`、`&4032>>6`、`&63`**，与标准 base64 一致只是字符集不同。
- padding 用 `=`（2/1 字节剩余情形）。

### ④ 输入编排 `getArr29`

把 `params`/`data`/`userAgent` 的 SM3 摘要 + 时间戳（`dt1`、`dt2=dt1-rand*10`、`(now-1721836800000)/1209600000`）+ UA 混淆串 + 固定常量（`6241`、`6383`）+ `parArr/dataArr` 特定下标（`parArr[9]`、`dataArr[10]`…）填入 55 字节 `arr`，经固定**置换表 `order`** 重排，拼上 `num...`、`lastNumOne`、`lastNum`（异或校验），最后 `getNumList` 每 3 字节插入随机噪声 → RC4 混淆 → base64 变体输出。

```go
func (c *ctx) generate(url, data, userAgent string) string {
    params := url[strings.Index(url,"?")+1:] + "dhzx"   // 后缀盐 "dhzx"
    data   += "dhzx"
    garbled := c.getGarbledString(params, data, userAgent)
    // topHeader(4字节) + abGarbledCharacters → 自定义 base64 → a_bogus
}
```
