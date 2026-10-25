# Pandahorn PVP Helper 0.5.1

Pandahorn PVP Helper 0.5.1 adds WoW: Forever support, independent target-highlight appearance controls, and compatibility safeguards while preserving the existing Retail behavior.

## Highlights

- Added support for **Retail 12.1 / 12.1.5** and **WoW: Forever 1.60.x** from the same addon package.
- Added independent UI configuration for Party/Raid Frame and nameplate target highlights:
  - Color
  - Thickness
  - Contrast
  - Border and outer-glow visibility
- WoW: Forever is detected automatically.
- Arena-only restrictions are ignored on Forever because arenas are not currently available.
- Friendly Identity remains enabled by default on Retail, but now defaults to **disabled on Forever**. Forever users can still enable it manually.
- Forever identity masking is limited to actual party/raid members and uses class/party-number fallbacks instead of incompatible Retail specialization IDs.
- Added safer client-specific event registration to avoid failures when an event is unavailable.

## Compatibility

| Client | Game type | Interface | Status |
|---|---|---:|---|
| Retail 12.1 | `standard` | `120100` | Supported |
| Retail 12.1.5 | `standard` | `120105` | Supported |
| WoW: Forever 1.60.x | `camelot` | `16001` | Supported |

The Settings UI and `PandahornPVPHelperDB` SavedVariables schema are shared across Retail and Forever. Existing settings are preserved during upgrade. Retail and Forever store SavedVariables under separate client/WTF directories, so settings are not synchronized automatically.

## Upgrade notes

- No configuration conversion or Lua-file editing is required.
- Existing Friendly Identity choices are preserved.
- On a fresh Forever installation, Friendly Identity starts disabled.
- The saved `arenaOnly` option remains effective on Retail and is ignored on Forever.
- On Forever, `{class}` and `{party}` are the recommended Friendly Identity tokens; `{spec}` is only populated where compatible specialization data is available.
- If the standalone `SimplePartyHighlight` addon is installed, disable or remove it to prevent duplicate highlight effects.

## Installation

Extract the `PandahornPVPHelper` folder into the appropriate AddOns directory:

- Retail: `World of Warcraft/_retail_/Interface/AddOns/`
- Forever beta: `World of Warcraft/_classic_beta_/Interface/AddOns/`

Open the configuration panel with:

`Esc → Options → AddOns → Pandahorn PVP Helper`

or `/pph settings`.

---

# 中文说明

Pandahorn PVP Helper 0.5.1 新增 WoW: Forever 支持、两套相互独立的目标高亮外观配置，并加入跨客户端兼容保护，同时保留正式服原有行为。

## 主要更新

- 同一个插件包支持 **正式服 12.1 / 12.1.5** 与 **WoW: Forever 1.60.x**。
- Party/Raid Frame 与姓名板目标高亮现在可以分别通过游戏内 UI 配置：
  - 颜色
  - 粗细
  - 对比度
  - 边框与外部光晕显示状态
- 自动识别 WoW: Forever 客户端。
- Forever 当前没有竞技场，因此会自动忽略仅限竞技场的限制。
- Friendly Identity 在正式服仍默认启用；在 Forever 上改为**默认关闭**，但仍可由玩家手动开启。
- Forever 中的姓名替换只作用于真实队伍/团队成员，并使用职业、队伍编号或 fallback 文本，不会错误套用正式服专精 ID。
- 使用更安全的客户端事件注册，降低客户端不存在某个事件时导致插件加载失败的风险。

## 配置与升级

- 不需要编辑 Lua 文件，也不需要转换配置。
- 正式服与 Forever 共用相同的 `PandahornPVPHelperDB` 配置结构。
- 升级时会保留已有设置，包括开关、颜色、粗细、对比度和姓名格式。
- Forever 全新安装时，Friendly Identity 默认关闭；已有用户的明确选择不会被覆盖。
- `arenaOnly` 在正式服继续生效，在 Forever 中保留但忽略。
- Forever 建议使用 `{class}` 和 `{party}` 姓名格式 token。
- 正式服与 Forever 的 WTF/SavedVariables 位于不同客户端目录，不会自动同步；如有需要，可以手动复制配置文件。

## 安装位置

- 正式服：`World of Warcraft/_retail_/Interface/AddOns/`
- Forever beta：`World of Warcraft/_classic_beta_/Interface/AddOns/`

通过以下方式打开设置：

`Esc → 选项 → AddOns → Pandahorn PVP Helper`

或输入 `/pph settings`。
