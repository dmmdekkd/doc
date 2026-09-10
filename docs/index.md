---
title: jumpbyte-bot 技术文档
description: 消息收发 / WebSocket / 算法 完全整理（版本对齐源码）
layout: home
hero:
  name: jumpbyte-bot
  text: IM 协议逆向研究实现
  tagline: 收消息走 WebSocket，发消息 HTTP / WS 双通道 · 裸 protobuf · 媒体 AES-GCM / CENC 解密
  badge:
    text: Go · 单静态二进制
    variant: info
features:
  - title: 🏗 架构总览
    details: cmd → engine → gateway 分层，收发 / WS / 算法全景图。
    link: /guide/architecture
    linkText: 查看架构
  - title: 🔌 消息收发
    details: 接收 WebSocket 全流程 + 发送 HTTP/WS 双通道。
    link: /guide/receive-flow
    linkText: 接收流程
  - title: 🧮 算法还原
    details: sign / a_bogus(SM3+RC4) / 媒体加解密逐行拆解。
    link: /algorithms/abogus
    linkText: 算法详解
  - title: 📦 源码模块
    details: 每个包、每个文件逐字节对齐的完整源码与声明索引。
    link: /modules/cmd-bot/index
    linkText: 浏览源码
---
