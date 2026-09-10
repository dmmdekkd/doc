export default [
  {
    "text": "指南",
    "items": [
      {
        "text": "简介",
        "link": "/guide/introduction"
      },
      {
        "text": "架构总览",
        "link": "/guide/architecture"
      },
      {
        "text": "快速开始",
        "link": "/guide/quickstart"
      },
      {
        "text": "接收消息流程",
        "link": "/guide/receive-flow"
      },
      {
        "text": "发送消息流程",
        "link": "/guide/send-flow"
      },
      {
        "text": "配置",
        "link": "/guide/configuration"
      },
      {
        "text": "自检与测试",
        "link": "/guide/testing"
      },
      {
        "text": "AI Skill 安装",
        "link": "/guide/skill"
      }
    ]
  },
  {
    "text": "协议",
    "items": [
      {
        "text": "WebSocket 协议",
        "link": "/protocols/websocket"
      },
      {
        "text": "Protobuf 编解码",
        "link": "/protocols/protobuf"
      },
      {
        "text": "事件协议",
        "link": "/protocols/events"
      }
    ]
  },
  {
    "text": "算法",
    "items": [
      {
        "text": "算法总览",
        "link": "/algorithms/overview"
      },
      {
        "text": "签名 sign",
        "link": "/algorithms/sign"
      },
      {
        "text": "a_bogus",
        "link": "/algorithms/abogus"
      },
      {
        "text": "媒体加解密",
        "link": "/algorithms/media-crypto"
      }
    ]
  },
  {
    "text": "网关 API",
    "items": [
      {
        "text": "网关 API",
        "link": "/api/gateway"
      }
    ]
  },
  {
    "text": "源码模块 (Modules)",
    "items": [
      {
        "text": "main-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/cmd-bot/index"
          },
          {
            "text": "main-go.go",
            "link": "/modules/cmd-bot/main-go"
          }
        ]
      },
      {
        "text": "config-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-config/index"
          },
          {
            "text": "bot-go.go",
            "link": "/modules/internal-config/bot-go"
          },
          {
            "text": "config-go.go",
            "link": "/modules/internal-config/config-go"
          }
        ]
      },
      {
        "text": "sign_test-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-sign/index"
          },
          {
            "text": "sign-go.go",
            "link": "/modules/internal-sign/sign-go"
          },
          {
            "text": "sign_test-go.go",
            "link": "/modules/internal-sign/sign_test-go"
          }
        ]
      },
      {
        "text": "hash_test-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-abogus/index"
          },
          {
            "text": "abogus-go.go",
            "link": "/modules/internal-abogus/abogus-go"
          },
          {
            "text": "abogus_test-go.go",
            "link": "/modules/internal-abogus/abogus_test-go"
          },
          {
            "text": "hash-go.go",
            "link": "/modules/internal-abogus/hash-go"
          },
          {
            "text": "hash_test-go.go",
            "link": "/modules/internal-abogus/hash_test-go"
          }
        ]
      },
      {
        "text": "smslogin_test-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-login/index"
          },
          {
            "text": "client-go.go",
            "link": "/modules/internal-login/client-go"
          },
          {
            "text": "device-go.go",
            "link": "/modules/internal-login/device-go"
          },
          {
            "text": "fingerprint-go.go",
            "link": "/modules/internal-login/fingerprint-go"
          },
          {
            "text": "helpers-go.go",
            "link": "/modules/internal-login/helpers-go"
          },
          {
            "text": "probe-go.go",
            "link": "/modules/internal-login/probe-go"
          },
          {
            "text": "qrlogin-go.go",
            "link": "/modules/internal-login/qrlogin-go"
          },
          {
            "text": "smslogin-go.go",
            "link": "/modules/internal-login/smslogin-go"
          },
          {
            "text": "smslogin_test-go.go",
            "link": "/modules/internal-login/smslogin_test-go"
          }
        ]
      },
      {
        "text": "qr_test-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-qr/index"
          },
          {
            "text": "qr-go.go",
            "link": "/modules/internal-qr/qr-go"
          },
          {
            "text": "qr_test-go.go",
            "link": "/modules/internal-qr/qr_test-go"
          }
        ]
      },
      {
        "text": "wssend_test-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-engine/index"
          },
          {
            "text": "client-go.go",
            "link": "/modules/internal-engine/client-go"
          },
          {
            "text": "convlist-go.go",
            "link": "/modules/internal-engine/convlist-go"
          },
          {
            "text": "convlist_test-go.go",
            "link": "/modules/internal-engine/convlist_test-go"
          },
          {
            "text": "engine_test-go.go",
            "link": "/modules/internal-engine/engine_test-go"
          },
          {
            "text": "group_frame_test-go.go",
            "link": "/modules/internal-engine/group_frame_test-go"
          },
          {
            "text": "httpsend-go.go",
            "link": "/modules/internal-engine/httpsend-go"
          },
          {
            "text": "httpsend_test-go.go",
            "link": "/modules/internal-engine/httpsend_test-go"
          },
          {
            "text": "imactions-go.go",
            "link": "/modules/internal-engine/imactions-go"
          },
          {
            "text": "imactions_test-go.go",
            "link": "/modules/internal-engine/imactions_test-go"
          },
          {
            "text": "proto-go.go",
            "link": "/modules/internal-engine/proto-go"
          },
          {
            "text": "upload-go.go",
            "link": "/modules/internal-engine/upload-go"
          },
          {
            "text": "upload_test-go.go",
            "link": "/modules/internal-engine/upload_test-go"
          },
          {
            "text": "video-go.go",
            "link": "/modules/internal-engine/video-go"
          },
          {
            "text": "video_frame_test-go.go",
            "link": "/modules/internal-engine/video_frame_test-go"
          },
          {
            "text": "video_test-go.go",
            "link": "/modules/internal-engine/video_test-go"
          },
          {
            "text": "videoplay-go.go",
            "link": "/modules/internal-engine/videoplay-go"
          },
          {
            "text": "wsconn-go.go",
            "link": "/modules/internal-engine/wsconn-go"
          },
          {
            "text": "wsconn_test-go.go",
            "link": "/modules/internal-engine/wsconn_test-go"
          },
          {
            "text": "wssend-go.go",
            "link": "/modules/internal-engine/wssend-go"
          },
          {
            "text": "wssend_test-go.go",
            "link": "/modules/internal-engine/wssend_test-go"
          }
        ]
      },
      {
        "text": "videoserver_test-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-media/index"
          },
          {
            "text": "cenc-go.go",
            "link": "/modules/internal-media/cenc-go"
          },
          {
            "text": "cenc_test-go.go",
            "link": "/modules/internal-media/cenc_test-go"
          },
          {
            "text": "image-go.go",
            "link": "/modules/internal-media/image-go"
          },
          {
            "text": "image_test-go.go",
            "link": "/modules/internal-media/image_test-go"
          },
          {
            "text": "imageserver-go.go",
            "link": "/modules/internal-media/imageserver-go"
          },
          {
            "text": "mp4cenc-go.go",
            "link": "/modules/internal-media/mp4cenc-go"
          },
          {
            "text": "mp4cenc_test-go.go",
            "link": "/modules/internal-media/mp4cenc_test-go"
          },
          {
            "text": "videoserver-go.go",
            "link": "/modules/internal-media/videoserver-go"
          },
          {
            "text": "videoserver_test-go.go",
            "link": "/modules/internal-media/videoserver_test-go"
          }
        ]
      },
      {
        "text": "gateway_test-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-gateway/index"
          },
          {
            "text": "gateway-go.go",
            "link": "/modules/internal-gateway/gateway-go"
          },
          {
            "text": "gateway_test-go.go",
            "link": "/modules/internal-gateway/gateway_test-go"
          }
        ]
      },
      {
        "text": "cache-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-store/index"
          },
          {
            "text": "cache-go.go",
            "link": "/modules/internal-store/cache-go"
          }
        ]
      },
      {
        "text": "im-go.go",
        "items": [
          {
            "text": "📘 概览",
            "link": "/modules/internal-webapi/index"
          },
          {
            "text": "im-go.go",
            "link": "/modules/internal-webapi/im-go"
          }
        ]
      }
    ]
  }
]
