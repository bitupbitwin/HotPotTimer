# 🍲 火锅捞捞 · 微信小程序版 (HotPotTimer Mini Program)

一个专为火锅爱好者设计的极简、直观的食材捞取时间管理工具 —— **微信小程序版本**。

> 📌 **本分支说明**：本仓库 `main` 分支保留原生 APP（Flutter）版本代码；本分支
> （`claude/wechat-miniprogram-repo-22cs9w`）是为上架微信小程序而移植的独立版本。
> 待创建 `HotPotTimer-miniprogram` 仓库后，可将本分支直接推送过去作为新仓库的 `main`：
>
> ```bash
> git push git@github.com:bitupbitwin/HotPotTimer-miniprogram.git claude/wechat-miniprogram-repo-22cs9w:main
> ```

---

## 🌟 功能亮点 (Key Features)

- **⏱️ 预设黄金时间**：内置 20 种经典火锅食材的推荐煮制时间（毛肚 15s、鸭肠 12s、虾滑 4min、潮汕牛肉丸 10min 等）。
- **⭕ 状态机呼吸光圈**：
  - **未下锅 (idle)**：黑色外圈，点击即可下锅启动计时。
  - **煮熟中 (counting)**：黄色光圈呼吸闪烁，实时倒计时。
  - **完美熟透 (ready)**：绿色光圈舒缓呼吸，触发**叮咚音效**与**震动提醒**。
  - **严重超时 (overcooked)**：红色光圈高频疯狂闪烁，每 15 秒循环催促。
- **📳 震动声效联动**：基于 `wx.vibrateShort` / `wx.vibrateLong` 与 `InnerAudioContext`，提供下锅轻触反馈、熟透提醒和超时警报。
- **🥣 蘸料方案**：内置 5 款经典蘸料配方（蒜泥油碟、麻酱、酸辣碟等），支持忌口标红与自定义方案。
- **📷 照片识别（占位实现）**：从相册选图 + 文字补充，关键词匹配已收录食材，预留接入真实视觉 API 的接口。
- **✏️ 自定义食材**：手动新增名字 + 倒计时秒数，微信本地缓存持久化。
- **🎨 极简黑金风 UI**：全暗色主题，凸显多彩状态指示环，与 APP 版视觉一致。

---

## 🏗️ 目录结构 (Directory Structure)

```text
.
├── app.js / app.json / app.wxss   # 小程序入口与全局配置（tabBar：蘸料/涮锅/我的）
├── project.config.json            # 微信开发者工具项目配置（appid 为测试号占位）
├── sitemap.json
├── utils/
│   ├── items.js                   # 食材静态预设数据（20 种食材 + 分类）
│   ├── sauces.js                  # 蘸料预设配方 + 忌口选项
│   ├── util.js                    # 计时状态机（由下锅时间推导状态）与时间格式化
│   ├── feedback.js                # 震动 / 声效统一反馈服务
│   ├── store.js                   # 本地持久化（微信 Storage）
│   └── recognition.js             # 照片识别占位层（关键词匹配）
├── pages/
│   ├── home/                      # 涮锅页（核心）：左侧分类 + 选菜网格 + 已点计时光圈
│   ├── seasoning/                 # 蘸料页：忌口设置 + 推荐/自定义蘸料方案
│   ├── profile/                   # 我的页：使用说明、意见反馈、隐私政策、版本
│   └── privacy/                   # 隐私政策页
└── assets/
    ├── images/                    # 食材实物图（<id>_<name>.png）
    └── sounds/                    # start / ready / overcooked 提示音
```

---

## 🛠️ 运行与调试 (Build & Run)

1. 下载并安装[微信开发者工具](https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html)。
2. 微信开发者工具 → 导入项目 → 选择本项目根目录。
3. AppID 选择「测试号」即可预览（`project.config.json` 中为 `touristappid` 占位；
   上架前请替换为你在[微信公众平台](https://mp.weixin.qq.com)注册的小程序 AppID）。
4. 点击「编译」，即可在模拟器中运行；「预览」可生成二维码在真机体验（真机才有震动反馈）。

### 上架前检查清单

- [ ] 替换 `project.config.json` 中的 `appid` 为正式 AppID
- [ ] 在 mp.weixin.qq.com 完善小程序名称、头像、类目（工具类）
- [ ] 后台「用户隐私保护指引」按 `pages/privacy` 内容填写（本项目仅使用相册选图，无需其他授权）
- [ ] 上传代码 → 提交审核 → 发布

---

## 📐 与 APP 版的对应关系

| APP（Flutter，main 分支） | 小程序（本分支） |
|---|---|
| `lib/data/default_items.dart` | `utils/items.js` |
| `lib/data/default_sauces.dart` | `utils/sauces.js` |
| `lib/models/selected_hotpot_item.dart`（状态推导） | `utils/util.js` |
| `lib/services/feedback_service.dart` | `utils/feedback.js` |
| `lib/services/*_store.dart`（SharedPreferences） | `utils/store.js`（wx Storage） |
| `lib/services/food_recognition_service.dart` | `utils/recognition.js` |
| `lib/screens/home_screen.dart` + `widgets/hotpot_item_widget.dart` | `pages/home/` |
| `lib/screens/seasoning_screen.dart` | `pages/seasoning/` |
| `lib/screens/profile_screen.dart` | `pages/profile/` |
| `lib/screens/privacy_policy_screen.dart` | `pages/privacy/` |

计时逻辑与 APP 版一致：状态永远由「下锅时间」实时推导（而非本地倒数），
因此切后台、杀进程后重新打开，计时依然准确。

---

## 🔒 隐私合规 (Privacy)

- 不收集任何个人信息，无第三方 SDK，所有数据存储在微信本地缓存。
- 相册选图通过 `wx.chooseMedia` 由微信代为完成，图片仅本地处理。
