# KB — 个人知识库

## 这是什么

未来的你的助理记忆。不是图书馆，不是工作笔记。

- 今天读懂、消化、改写过的资料，1 年 / 3 年 / 10 年后突然需要时，Claude 帮你 30 秒召回
- 原始文件可能埋在外部网盘深处 — 你不用记位置，kb 记
- 你不用记结论 — wiki 记

## 心态条款（最重要，先读这个）

| 错的心态 | 对的心态 |
|---|---|
| 收集所有资料 | 只收"未来某天有可能用一次"的 |
| 必须每周用才有价值 | 3 年后突然召回得准才有价值 |
| 改写 wiki 是为了省 token | 改写 wiki 是给"已经忘了原文"的未来的你看的 |
| Wiki 写得糙没关系 | Wiki 写糙 = 召回拿到垃圾 = 整个系统废 |

**ingest 标准：** "未来有可能用一次" 就够，不限频率。
**不 ingest：** "我永远不会再回看的废稿"。

## 怎么用速查

| 操作 | 怎么做 |
|---|---|
| 加新资料 | 拷进 `inbox/`（必要时先转写/导出 PDF） |
| 消化 inbox | Claude Code 里说"ingest 一下"或 `/kb-ingest` |
| 找文件（自己） | Obsidian `Cmd+O` / Tag 面板 / OS 全文搜 |
| 找文件（Claude） | 自然语言问，它自己 Read INDEX + Grep wiki |
| 看原视频 / 原 PPT | 查 frontmatter `source_external`，从外部存储下载 |

## 目录结构

```
~/kb/
├── README.md              ← 本文件
├── INDEX.md               ← Agent 入口，wiki 索引
├── SCHEMA.md              ← Ingest/Query/Lint 规则
├── tags-vocabulary.md     ← tag 真理来源（防漂移）
├── external-media.md      ← 外部存储原档索引（可选）
├── inbox/                 ← 投递区，你只管丢，Claude 处理
├── sources/               ← 归档区（Claude 写）
│   ├── work/
│   ├── learning/
│   ├── life/              ← 兜底：生活/家庭/兴趣/健康/财务/育儿
│   └── reference/         ← 行业报告/通用资料
└── wiki/                  ← LLM 主战场，改写后笔记
```

## 与其他系统的边界

- **Claude memory**（`~/.claude/.../memory/`，"Claude 对你的认知：身份/规则"）— **物理分离**，不互通
- **外部网盘 / OSS / NAS** — 大原档（视频/PSD/大 PDF）的统一归宿，kb 通过 frontmatter 引用

## 详细规则

见 [SCHEMA.md](SCHEMA.md)。
