# kb-starter — Karpathy LLM Wiki Pattern 个人知识库脚手架

把任何资料（PDF / docx / 转写 / 截图 / 英文播客）扔进 `inbox/`，跟 Claude Code 说"ingest 一下"，自动改写成**给未来的你看的**结构化 wiki + 双向回填 + git 留痕。

> 灵感：[Karpathy LLM Wiki Pattern](https://x.com/karpathy/status/1746345242612097456)
> 适合：长期个人档案 / 多年后召回 / 跨多源主题合并 / 给 Claude 当 RAG-replacement

## 这套系统适合谁

| ✅ 适合 | ❌ 不适合 |
|---|---|
| 你想 3-10 年后突然能查到今天读过的东西 | 你只想要一个能搜的笔记本 |
| 你愿意花 10 分钟让 Claude 把一份 PDF 改写成主题驱动笔记 | 你只想把原文塞进去全文搜 |
| 你有多个信息源（课程 / 博客 / 播客 / 公司文档）想跨源整合 | 你只有一种资料类型 |
| 你已经在用 Claude Code（或愿意配） | 你不打算用 LLM 辅助 |

## 30 秒速览

```
~/kb/
├── inbox/         你扁平扔进任何格式 → Claude 处理
├── sources/       归档：精华 .md + 原档同目录共用 slug
├── wiki/          主题驱动改写后的笔记（LLM 主战场）
├── INDEX.md       agent 入口
├── SCHEMA.md      规则书（一级 tag 固定 7 个、frontmatter、决策树…）
└── tags-vocabulary.md  tag 真理来源
```

**典型流程**：

```
你：把这份 PDF 拖进 ~/kb/inbox/
你：跟 Claude 说"ingest 一下"
Claude：[读 SCHEMA + INDEX + tags-vocabulary]
        [分页全读 PDF（不抽样）]
        [报告归档计划 + 跨 wiki 主题合并机会]
        [等你点头]
        [写 wiki/ + 挪 source/ + 双向回填 frontmatter + git commit]
你：完事，inbox 空了
```

## 安装

3 步：

```bash
# 1. clone 本 repo
git clone https://github.com/<your-username>/kb-starter.git
cd kb-starter

# 2. 跑 init 脚本（交互式：问 kb 路径、复制模板、git init、软链 skill）
./init.sh

# 3. 开 Claude Code，跟它说"ingest 一下"
```

完整说明：[INSTALL.md](INSTALL.md)

## 文档导航

| 文档 | 干嘛 |
|---|---|
| [INSTALL.md](INSTALL.md) | 3 步安装 + 故障排查 |
| [DESIGN.md](DESIGN.md) | **5 个核心理念**（为什么这么设计，先读这个再改） |
| [EXAMPLE.md](EXAMPLE.md) | 一份 PDF 从 inbox 到 wiki 的完整 walkthrough |
| [obsidian-setup.md](obsidian-setup.md) | 可选 companion：Obsidian + Dataview 把 frontmatter 变仪表盘 |
| [kb-template/SCHEMA.md](kb-template/SCHEMA.md) | 装好后 `~/kb/SCHEMA.md` 的内容，规则真理来源 |
| [skills/kb-ingest/SKILL.md](skills/kb-ingest/SKILL.md) | kb-ingest skill 本体，了解 Claude 在做什么 |

## 跟原作者的私人版本有什么差异

本 starter 是 [原作者](https://github.com/<your-username>) 自用 kb 系统的**脱敏抽象版**：

- ✅ 保留：完整 `kb-ingest` skill + SCHEMA + 7 个一级 tag + frontmatter 规范 + git 流程 + 双向回填 + 跨 wiki 主题合并 + Mermaid 可视化 + 双语翻译规则
- ❌ 移除：原作者私有的 `kb-lint` / `kb-archive` / `kb-translate-cn` skill（按需自己实现）
- ❌ 移除：原作者私人项目名 / 课程名 / 人名 / 团队名 / 公司云存储路径
- 📝 模板化：INDEX.md / tags-vocabulary.md / external-media.md 都改成空模板，让你按自己的项目长出来

如果你想看更完整的实战形态（带几百份 wiki 已经长出来的样子），找原作者私聊要 demo。

## 心态条款

| 错的心态 | 对的心态 |
|---|---|
| 收集所有资料 | 只收"未来某天有可能用一次"的 |
| 必须每周用才有价值 | 3 年后突然召回得准才有价值 |
| 改写 wiki 是为了省 token | 改写 wiki 是给"已经忘了原文"的未来的你看的 |
| Wiki 写得糙没关系 | Wiki 写糙 = 召回拿到垃圾 = 整个系统废 |

**ingest 标准：** "未来有可能用一次" 就够，不限频率。
**不 ingest：** "我永远不会再回看的废稿"。

## License

MIT
