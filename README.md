# tw93-skills — Tw93 Skills 的 Kimi Code 插件

[Tw93](https://github.com/tw93) 的技能打包为 [Kimi Code CLI 插件](https://moonshotai.github.io/kimi-code/zh/customization/plugins.html)：工程习惯（Waza）加文档排版（kami），共 9 个技能。上游两个仓库，均为 MIT：

- [tw93/Waza](https://github.com/tw93/Waza) —— check、health、hunt、learn、read、think、ui、write
- [tw93/kami](https://github.com/tw93/kami) —— kami

## 安装

TUI 中二选一，装完 `/reload`（或 `/new`）生效：

```
/plugins install http://lzxsvn:3000/qinyuanj/tw93-skills/archive/main.zip
```

```bash
git clone http://lzxsvn:3000/qinyuanj/tw93-skills.git
/plugins install /path/to/tw93-skills   # 在 TUI 中执行
```

本地安装会被拷到 `$KIMI_CODE_HOME/plugins/managed/tw93-skills/` 运行，之后编辑源目录不会生效，需重新安装。

## 更新

重跑安装命令即可（zip 源永远指向最新 main；本地安装则重跑 `/plugins install /path/to/tw93-skills`），或进 `/plugins` 的 Installed 页选中本插件按 Enter 安装可用更新。

更新检测依据 `kimi.plugin.json` 的 `version`，本仓库把它对齐 Waza 的 `VERSION`（当前 3.35.0），`sync-upstream.sh` 同步时会一起更新。

## 技能清单

`skills/` 下每个目录一个技能，用途写在各自 `SKILL.md` 里。手动触发用 `/skill:<名字>`，模型匹配到场景时也会自动调用。

- **think** —— 动工前把粗糙想法压成决策完整的方案
- **ui** —— 做有观点的界面，含截图驱动的审美迭代
- **check** —— 收尾、合并、发布前：审 diff、核结果、走发布动作
- **hunt** —— 先定根因再动手的排障纪律
- **write** —— 中英文润色去 AI 味，含发布说明与本地化文案
- **learn** —— 陌生领域的六阶段研究流程
- **read** —— 读 URL / PDF，按需给摘要或干净 Markdown
- **health** —— 审 agent 配置、指令漂移、hooks / MCP 与 AI 可维护性
- **kami** —— 文档排版与落地页：简历、一页纸、白皮书、slides、landing page

## 与上游的差异

`skills/` 与上游逐字一致（`scripts/sync-upstream.sh` 可复现），Kimi 专属资产（`kimi.plugin.json`、本 README、脚本）一律放在 `skills/` 之外。唯一例外是 `skills/kami/assets/examples/`：它是 kami 打包期产物，上游 git 里没有，这里留了一份。

技能正文里的 `/hunt`、`/check` 一类引用指同名技能，在 Kimi 里用 `/skill:hunt` 触发；本仓库只收 Tw93 的技能，`slidev`（slidevjs）与 `writing-for-agents`（Matt Pocock）不在此列。

若项目里已经有同名 skill（例如某个仓的 `.agents/skills/`），插件与项目两处会各注册一份，建议只留一处。

## 同步上游

```bash
scripts/sync-upstream.sh                  # 两边都取最新 tag
scripts/sync-upstream.sh v3.38.0          # 指定 Waza ref
scripts/sync-upstream.sh v3.38.0 V1.16.0  # 两边都指定
```

同步点记在 `UPSTREAM`，跑完看一眼 `git diff` 即可提交。

## License

MIT，版权归 Tw93，见 [LICENSE](LICENSE)；kami 另有自己的 LICENSE（`skills/kami/LICENSE`）。
