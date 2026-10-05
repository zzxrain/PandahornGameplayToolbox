# 开发与维护

面向插件开发者的技术说明；使用说明及效果截图见 [README](README.md)。

## 运行环境与验证

插件当前版本为 0.4.0，目标为 WoW Retail 12.1，清单标注 `Interface: 120100`。
云环境没有 WoW 客户端，Lua 加载和模拟检查不能代替游戏内验证。
发布前按 [TESTING.md](TESTING.md) 检查设置、竞技场行为及第三方插件兼容性。
BugSack / BugGrabber 可用于收集完整 Lua 错误堆栈。

## 打包

macOS 使用系统自带 Bash 和 `zip`，无需 Python。在仓库根目录运行：

```sh
./scripts/package.sh
```

脚本也支持从其他工作目录调用。版本号及 Lua 文件列表来自 `.toc`，
同时收集 `## IconTexture:` 指向的插件内图标。
输出为 `dist/PandahornGameplayToolbox-<version>.zip`，最外层目录为 `PandahornGameplayToolbox/`。
当前包只包含清单、7 个 Lua 文件和 `Media/addon_icon.tga`，共 9 个文件。

脚本在创建安装包前验证文件存在性和路径，拒绝符号链接，成功后才替换已有 ZIP。
文档、截图原图、Git 元数据、脚本及开发输出均不进入安装包。

## 图片资源

- `Media/addon_icon.tga`：游戏内插件列表图标，由 `.toc` 的 `IconTexture` 指定。
- `assets/previews/*.png`：README 功能截图，保留用户提供的原图，仅用于文档。

## 架构

| 文件 | 职责 |
| --- | --- |
| `Core.lua` | 生命周期、按顺序初始化模块、SavedVariables、竞技场检测、回调及 secret-value 安全处理 |
| `Data/Specs.lua` | 职业与专精简称 |
| `Services/Inspect.lua` | 节流 inspect 队列、GUID 与专精缓存 |
| `Modules/FriendlyIdentity.lua` | 队友／目标框架重命名及格式解析 |
| `Modules/PartyTargetHighlight.lua` | 小队框架当前目标边框与外发光 |
| `Modules/NameplateTargetHighlight.lua` | 当前目标姓名板高亮 |
| `UI/Settings.lua` | Blizzard Settings 设置页面 |

新功能通过 `PGT:RegisterModule()` 注册独立模块。设置保存于 `PandahornGameplayToolboxDB`，
当前 `dbVersion = 4`，初始化保留已有设置并补充缺失的默认值。

## 行为细节

Friendly Identity 仅在竞技场生效，专精通过 inspect API 获取并按 GUID 缓存。
专精尚不可用时回退为职业、队友编号或 `Ally`，避免在遮蔽状态下显示队友真实姓名。

Party Target Highlight 使用暴雪 `selectionHighlight:IsShown()` 判断选中状态，
避免额外调用 `UnitIsUnit()`。姓名板高亮采用事件驱动，保留单个活动姓名板引用，
不做逐帧扫描；独立高层覆盖用于与 BetterBlizzPlates 等姓名板皮肤配合。
实际兼容性仍需在游戏中验证。

姓名格式支持 `{spec}`、`{class}`、`{party}`：

| 模板 | 示例 |
| --- | --- |
| `{spec} {class}` | `Holy Pal` |
| `{spec} {class} {party}` | `Holy Pal P1` |
| `{class} {party}` | `Pal P1` |
| `{party} {spec} {class}` | `P1 Holy Pal` |
| `{spec}-{class}-{party}` | `Holy-Pal-P1` |

`{party}` 对应 `party1` / `party2` 等单位编号；其他插件重排框架时，编号可能与屏幕顺序不同。
