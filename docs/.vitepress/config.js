import { defineConfig } from 'vitepress'
import sidebar from './sidebar.js'

export default defineConfig({
  base: "/doc/",
  title: "jumpbyte-bot",
  description: "消息收发 / WebSocket / 算法 完全整理（版本对齐源码）",
  cleanUrls: true,
  lastUpdated: true,
  themeConfig: {
    nav: [
      { text: "指南", link: "/guide/introduction" },
      { text: "协议", link: "/protocols/websocket" },
      { text: "算法", link: "/algorithms/overview" },
      { text: "API", link: "/api/gateway" },
      { text: "源码", link: "/modules/cmd-bot/index" },
    ],
    sidebar,
    outline: { level: [2, 3], label: "本页目录" },
    docFooter: { prev: "上一篇", next: "下一篇" },
    footer: {
      message: "基于真实源码版本对齐生成 · GPL-3.0",
      copyright: "仅供学习研究，请遵守相关法律法规与服务条款",
    },
    search: { provider: "local" },
  },
})
