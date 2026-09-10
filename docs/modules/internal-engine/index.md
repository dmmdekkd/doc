# engine — IM 引擎

> package `engine` &nbsp;·&nbsp; 源码版本 main @ b252442 (2026-09-03)


## 文件清单

- [`client.go`](./client-go.md) — 10 个声明
- [`convlist.go`](./convlist-go.md) — 10 个声明
- [`convlist_test.go`](./convlist_test-go.md) — 1 个声明
- [`engine_test.go`](./engine_test-go.md) — 11 个声明
- [`group_frame_test.go`](./group_frame_test-go.md) — 1 个声明
- [`httpsend.go`](./httpsend-go.md) — 18 个声明
- [`httpsend_test.go`](./httpsend_test-go.md) — 3 个声明
- [`imactions.go`](./imactions-go.md) — 9 个声明
- [`imactions_test.go`](./imactions_test-go.md) — 4 个声明
- [`proto.go`](./proto-go.md) — 11 个声明
- [`upload.go`](./upload-go.md) — 11 个声明
- [`upload_test.go`](./upload_test-go.md) — 1 个声明
- [`video.go`](./video-go.md) — 8 个声明
- [`video_frame_test.go`](./video_frame_test-go.md) — 1 个声明
- [`video_test.go`](./video_test-go.md) — 2 个声明
- [`videoplay.go`](./videoplay-go.md) — 4 个声明
- [`wsconn.go`](./wsconn-go.md) — 9 个声明
- [`wsconn_test.go`](./wsconn_test-go.md) — 2 个声明
- [`wssend.go`](./wssend-go.md) — 14 个声明
- [`wssend_test.go`](./wssend_test-go.md) — 4 个声明

## 本包 API 速览


### `client.go`

- `const androidSendWsBase, akFpID, akAppKey, akSalt, awemeAID, awemeVersionCode, awemeVersionName, awemeUpdateVersionCode, awemeChannel, awemeDeviceType, awemeDeviceBrand, awemeOSVersion, awemeOSAPI, awemeAppName, awemeAppPackage, awemeUA, awemeSDKVersion, awemeBuildNumber2` — L20  : -- 常量（来自 ImClient.ts）------------------------------------------------
- `type ImImage` — L48  : -- 对外类型 ---------------------------------------------------------------
- `func (ImImage) PickURL` — L62  : PickURL 取一个可用的原图 URL（优先 origin，其次 large/medium/thumb）。
- `type ImVideo` — L72  : ImVideo 视频消息资源。视频流用 tkey 走 batch_play_info 换可播 URL；poster 是封面图（可解密）。
- `type ImEmoji` — L83  : ImEmoji 表情消息（aweType 507）。url 是明文图地址（im-resource），可直接展示，无需解密。
- `type IncomingMessage` — L93  : IncomingMessage 投递给上层的一条收到的消息。
- `type Client` — L107  : Client frontier-aweme IM 客户端（单账号）。
- `func (Client) resolveShort` — L119  : resolveShort 发送时若未显式给 short_id，用收包学到的缓存回填。
- `func New` — L130  : New 创建客户端。uid 为账号 user_id。
- `func (Client) nextSeq` — L134

### `convlist.go`

- `const imapiConvListURL` — L10  : 会话列表(cmd 2006)：私信 + 群聊都在里面。逆自真机 HAR imapi /v1/conversation/list。
- `type ConvMember` — L13  : ConvMember 会话成员。
- `type Conversation` — L20  : Conversation 一条会话（群或单聊）。
- `func (Client) ListConversations` — L32  : ListConversations 拉会话列表（cmd 2006）。count 拉取条数（默认 20）。
- `func parseConvListResp` — L58  : parseConvListResp 解会话列表响应：f6 → f2006 → 重复的 f1 每个是一条会话。
- `func parseConversation` — L70
- `func childMsgs` — L104  : -- ProtoField 小工具（repeated 感知；searchPath 只取首个 varint，这里补齐）------
- `func firstMsg` — L114
- `func firstStr` — L123
- `func firstVarint` — L132

### `convlist_test.go`

- `func TestParseConvList` — L9  : 用真机 conv/list 响应验证解析：应解出 4 条会话，首条是群、带成员(uid+sec_uid)。

### `engine_test.go`

- `func mustJSON` — L11
- `func md5Ref` — L18
- `func TestKvPairRoundTrip` — L24  : protobuf 编解码往返：KV pair。
- `func TestVarintRoundTrip` — L37  : varint 往返（含大 ID）。
- `func TestBuildAndCollectRoundTrip` — L48  : 发送帧结构 + 收包往返：buildIMAPIBody 造帧（外层 f1=cmd=100），collectChat 能抠回文本。
- `func TestJSONNoEscape` — L73  : JSON 内容编码：不转义 &amp; &lt; &gt; /，中文原样（对应 UNESCAPED_UNICODE|UNESCAPED_SLASHES）。
- `func TestParseImageItem` — L87  : 图片消息解析：aweType 2702 → 抠出 skey 与 origin_url_list。
- `func TestParseImageNoText` — L105  : 真实的纯图片消息（无 text 字段）也要能解出，text 占位 [图片]。
- `func TestSelfDirection` — L136  : 自己发的消息应判为 sent。
- `func TestAccessKey` — L147  : access_key = md5(fpid+appkey+deviceId+salt)。
- `func TestRawURLEncode` — L160  : rawURLEncode = PHP rawurlencode（RFC3986）。

### `group_frame_test.go`

- `func TestGroupEmojiFrame` — L10  : 用真机群聊表情帧跑收包路径：验证群消息(纯数字 conv_id)、表情(aweType 507)不被丢、

### `httpsend.go`

- `const imapiSendURL, imapiRecallURL, imapiPropURL, webSDKVersion, webBuildNumber, webSessionAID, webAppName, webBiz, webAccess, pcUA` — L17  : 电脑版(douyin_pc / imapi) 走 HTTP，body 是 application/x-protobuf（与 WS 帧同构，去掉 frontier 外壳）。
- `const convTypeSingle, convTypeGroup` — L31  : 会话类型(field100.f2)：1=单聊(私信)，2=群聊。私信/群聊发送同一端点，只有此字段与 short_id 不同。
- `const msgTypeText, msgTypeEmoji, msgTypeImage, msgTypeVideo` — L37  : 消息类型(field100.f6)：按内容种类取值（与会话类型无关，逆自真机 HAR：私信/群聊同一套）。
- `func isGroupConv` — L45  : isGroupConv 群会话 id 是纯数字（如 7681236801654178341）；私信是 "0:1:小:大"。
- `var imHTTP, uploadHTTP` — L50  : 复用 http.Client 以复用连接（TLS 握手）。imHTTP 用于短请求，uploadHTTP 用于上传/分片。
- `type imapiTextContent` — L56  : imapiTextContent 文本 content JSON（字段顺序照 HAR：aweType,type,richTextInfos,text）。
- `type ImageAsset` — L64  : ImageAsset upload_image 的产物，喂给发图。
- `type imapiImageContent` — L74  : imapiImageContent 图片 content JSON（字段顺序照 HAR）。
- `func (Client) deviceID` — L89
- `func fingerprintKVs` — L97  : fingerprintKVs f15 里的浏览器指纹 KV（session_did 用给定 device_id）。
- `func (Client) buildEnvelope` — L109  : buildEnvelope imapi 通用外壳：cmd + f8(内层 fieldNum→inner) + 指纹。所有动作共用。
- `func (Client) buildIMAPIBody` — L134  : buildIMAPIBody 组发消息(cmd100)的 body，返回 (body, clientMsgID)。
- `func (Client) postIMAPIRaw` — L152  : postIMAPIRaw POST 一段 protobuf 到 imapi，返回响应字节。
- `func (Client) resolveConvSend` — L175  : resolveConvSend 由 convID 形态定发送用的 (conv_type, short_id)：
- `func (Client) dispatchSend` — L187  : dispatchSend 按 SendChannel 选发送通道：ws 走安卓 frontier WS，否则(默认)走 HTTP imapi。
- `func (Client) sendIMAPI` — L195  : sendIMAPI 发消息(cmd100)并解析回执（f3=status,0=OK；f6→f100→f1=server_msg_id）。
- `func u64str` — L217
- `func snippet` — L224

### `httpsend_test.go`

- `func TestBuildIMAPIBodyMatchesHAR` — L11  : 我们硬拼的 body 应与真机 HAR 逐字节同构：静态字段的编码字节两边都在。
- `func TestParseSendResponse` — L65  : 回执解析：status=0(OK) + server_msg_id 从 f6→f100→f1 取。
- `func TestImageContentShape` — L81  : 图片 content 结构：resource_url 在前、aweType=2702 在后，字段顺序照 HAR。

### `imactions.go`

- `func (Client) Recall` — L12  : 撤回 / 表情 / 回复：共用 imapi 外壳(buildEnvelope)，只有 cmd 号与内层不同。逆自真机 HAR。
- `type imapiEmojiURL` — L36  : -- 表情（cmd 100，aweType 507）------------------------------------------
- `type imapiEmojiContent` — L44
- `type EmojiSpec` — L62  : EmojiSpec 发表情入参。URL 是表情图地址（可从表情库拿）。
- `func (Client) SendEmojiResult` — L71  : SendEmojiResult 发一个表情。
- `type imapiReplyContent` — L93  : -- 回复（cmd 100，content 带 refmsg_*）-----------------------------------
- `type ReplySpec` — L106  : ReplySpec 回复入参。RefText 是被回复消息的原文（用于重建 refmsg_content）。
- `func (Client) SendReplyResult` — L114  : SendReplyResult 回复一条消息（引用原文）。
- `func ParseUint` — L124  : ParseUint 宽松解析无符号整数（供网关拼 server_msg_id / short_id）。

### `imactions_test.go`

- `func TestRecallBodyMatchesHAR` — L11  : 撤回 body：cmd=702，f702{conv_id, short_id, 1, server_msg_id} 的编码字节应出现在 HAR 里。
- `func TestEmojiContent` — L40  : 表情 content：aweType 507 + 关键字段。
- `func TestReplyContent` — L62  : 回复 content：refmsg_type 7 + refmsg_content 内嵌原文 JSON。
- `func (Client) buildEmojiContentForTest` — L89  : buildEmojiContentForTest 仅测试用：产出表情 content JSON。

### `proto.go`

- `type ProtoField` — L14  : ProtoField 宽松 protobuf 字段（imapi 无公开 .proto，按 wire type 猜）。
- `func encodeVarint` — L26  : -- 编码 -------------------------------------------------------------------
- `func encodeTag` — L35
- `func encodeFieldVarint` — L39
- `func encodeLenDelim` — L43
- `func encodeLenDelimS` — L49
- `func encodeKvPair` — L53
- `func concat` — L58
- `func decodeVarintAt` — L69  : -- 解码 -------------------------------------------------------------------
- `func tryUtf8` — L89  : tryUtf8 能安全当文本就返回 (s,true)；含控制字符或非法 UTF-8 返回 ("",false)。
- `func decodeProtobuf` — L102  : decodeProtobuf 宽松解码：像 JSON 的当字符串，其余尝试递归当子消息。

### `upload.go`

- `const uploadConfigURL, vodBase, vodRegion, vodService` — L28  : 图片上传：走电脑版的 TOS/VOD 上传链（标准 AWS SigV4 签名），拿到发图用的 ImageAsset。
- `type stsCreds` — L35
- `func (Client) UploadImage` — L43  : UploadImage 上传图片字节，返回可直接发送的 ImageAsset。
- `func (Client) getUploadConfig` — L75  : getUploadConfig GET config/v2 拿 STS 凭证 + space_name（cookie 鉴权，无 a_bogus）。
- `func (Client) applyUpload` — L106  : applyUpload GET ApplyUploadInner（SigV4）→ storeURI, auth(JWT), uploadHost, sessionKey。
- `func (Client) tosPut` — L153  : tosPut 把图片字节 PUT/POST 到 TOS。
- `func (Client) commitUpload` — L178  : commitUpload POST CommitUploadInner（SigV4）→ oid(Encryption.Uri), skey, md5。
- `func vodSignedRequest` — L213  : -- AWS SigV4 --------------------------------------------------------------
- `func vodSign` — L234  : vodSign 纯计算：返回 Authorization 头 + 需随请求发送的签名头（可注入时间戳，便于对拍）。
- `func canonicalQuery` — L270  : canonicalQuery 键排序后 RFC3986 编码拼接（AWS 规则）。
- `func sha256Hex` — L283

### `upload_test.go`

- `func TestVodSigV4MatchesHAR` — L12  : 用真机 HAR 抓到的 STS 凭证 + 时间戳复算 ApplyUploadInner 的 SigV4 签名，

### `video.go`

- `const videoPartSize` — L15  : 发视频：封面走图片上传(UploadImage)拿 poster，视频走 TOS 分片上传(init→transfer→finish→commit)拿 video，
- `type imapiVideoContent` — L17
- `func (Client) SendVideoResult` — L34  : SendVideoResult 发视频。cover 是封面图字节（必填，用作 poster + 审核图）。width/height 传 0 则用封面尺寸兜底。
- `func (Client) uploadVideo` — L77  : uploadVideo TOS 分片上传视频，返回 tkey/skey/md5。
- `func (Client) chunkInit` — L108  : chunkInit phase=init，返回 uploadid。
- `func (Client) chunkTransfer` — L135  : chunkTransfer phase=transfer 上传一片。
- `func (Client) chunkFinish` — L157  : chunkFinish phase=finish，body 为 "1:crc,2:crc,..."。
- `func (Client) uploadCheckPic` — L177  : uploadCheckPic 把封面传到 maya_review 空间作审核图，返回 StoreUri（失败返回 ""，不阻断发送）。

### `video_frame_test.go`

- `func TestExtractVideoFrame` — L9  : 用真机完整视频帧跑一遍收包路径：帧字节 → decodeTop → collectChat → parseChatJsonItem → 视频条目。

### `video_test.go`

- `func TestVideoContentShape` — L11  : 视频 content 字段顺序应与 HAR 一致：video{tkey,md5,skey},poster{oid,md5,skey},height,width,check_pics。
- `func TestVideoChunkPlan` — L25  : 分片计划：12MB → 3 片(5+5+2)，part list 形如 "1:crc,2:crc,3:crc"（对齐 HAR finish body）。

### `videoplay.go`

- `const batchPlayInfoURL` — L14
- `func (Client) pcFingerprintQuery` — L17  : pcFingerprintQuery 电脑版 web 接口通用的设备指纹 query（config/v2、batch_play_info 共用，无 a_bogus）。
- `type VideoURL` — L39  : VideoURL 视频可播地址（batch_play_info 解出）。视频流本身仍是加密的（key=消息里的 video.skey）。
- `func (Client) ResolveVideoURL` — L46  : ResolveVideoURL 用视频 tkey 走 batch_play_info 换可播 URL（main/backup）。

### `wsconn.go`

- `type WsProxy` — L19  : WsProxy 出口代理（socks5 默认，或 http/https）。
- `const maxFrameBytes` — L25
- `type WsConn` — L28  : WsConn 对应 TS WsConnection：连接（可走代理）+ receive(timeout) 拉模型收包 + send/ping/close。
- `func wsConnect` — L39  : wsConnect 建立连接；握手失败抛错。headers 里的 Sec-WebSocket-Protocol 会转成子协议。
- `func applyProxy` — L88
- `func (WsConn) reader` — L126
- `func (WsConn) setClosed` — L141
- `func (WsConn) err` — L153
- `func (WsConn) IsOpen` — L161  : IsOpen 连接是否可用。

### `wsconn_test.go`

- `func TestWsFollowsEnvProxy` — L11  : 无显式代理时 WS 拨号器应跟随环境代理（HTTP(S)_PROXY），这样 WS 能和 HTTP 一样经终端代理抓包。
- `func TestWsExplicitHTTPProxy` — L31  : 显式 http 代理直接生效。

### `wssend.go`

- `const wsSendBiz, wsSendAccess` — L22  : WS 发送通道：走安卓 frontier(/ws/v2) 发 cmd100 帧，绕开 HTTP imapi(douyin_pc web_sdk)群聊被风控(7523)的问题。
- `type wsCh1TextContent` — L29  : wsCh1TextContent 安卓 douyin_main(ch1) 的文本 content（字段顺序照 TS buildSendMessage case 1）。
- `func wsAdaptContent` — L42  : wsAdaptContent 把上层(按 HTTP/web 形状)造好的 content 适配成 WS(安卓 ch1)形状。
- `func (Client) sendViaWS` — L65  : sendViaWS 通过安卓 frontier WS 发一条消息，读回执拿 server_msg_id；被风控拦截则明确报错。
- `func (Client) buildWSSendPayload` — L97  : buildWSSendPayload 组一条 WS cmd100 发送帧，返回 (帧字节, client_msg_id)。
- `func (Client) buildAndroidCmd100Inner` — L123  : buildAndroidCmd100Inner 安卓 IM SDK 的 cmd100 内层外壳（对应 HTTP 侧 buildEnvelope 的安卓版）。
- `func wrapAndroidCmd100Outer` — L153  : wrapAndroidCmd100Outer frontier 上行外层帧。
- `func androidSendExt` — L173  : androidSendExt ch1(douyin_main) 的 f5 ext KV（含时间戳，逆自 TS buildSendMessage case 1）。
- `var androidSendExt12` — L199
- `type wsAck` — L210  : -- 回执 -------------------------------------------------------------------
- `func (Client) drainSendAck` — L218  : drainSendAck 发完后读回执帧直到拿到本条的 ack 或超时。回执结构同收包帧：
- `func matchSendAck` — L236
- `func blockedCallback` — L264
- `func collectKV` — L273  : collectKV 收集重复 KV 字段(fieldNum){f1:key, f2:val}。

### `wssend_test.go`

- `func TestBuildWSSendPayloadGroup` — L9  : WS 群聊发送帧结构：解回自己造的帧，逐层核对 外层/内层(安卓)/field100(复用 conv_type/msg_type/content)。
- `func TestWSAdaptContent` — L75  : wsAdaptContent 只换纯文本；引用回复(refmsg_*)与图片/表情/视频原样放行。
- `func TestBuildWSSendPayloadImageMsgType` — L95  : 图片走 WS 时 msg_type 应=27（复用内容层的类型判定）。
- `func TestMatchSendAck` — L109  : 回执匹配：按 s:client_message_id 命中本条，取 f3=server_msg_id；风控 BLOCK 判未送达。