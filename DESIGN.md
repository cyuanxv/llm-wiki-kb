# DESIGN — 5 个核心理念

> 改这套系统前先读完本文。理解 Why 后你可以按自己需要改任何细节；不理解 Why 直接乱改 → 系统会逐步崩塌（tag 爆炸、wiki 互相引用断链、原档丢失、改写质量退化）。

## 1. inbox / sources / wiki 三段分离

```
inbox/         ← 原料区（你扔，Claude 处理完必清空）
sources/       ← 档案区（原始资料的精华版 + 原档，Claude 写）
wiki/          ← LLM 主战场（主题驱动改写后的笔记）
```

**为什么分三段，不是一个目录？**

- **inbox 是 transient** —— 一刀切 .gitignore，避免你扔一堆 zip / 截图 / 临时草稿污染 git 历史
- **sources 是档案** —— 永久保存"这份资料的精华提取"，给"未来某天突然想看原文细节"用
- **wiki 是给未来的你看的** —— 跨多个 sources 主题驱动改写，删了 source 也能自包含读懂

**反 pattern**：很多人把 inbox + sources + wiki 合成一个 notes/ 目录，三个月后就会陷入"我到底是该 grep 原文还是 grep 笔记"的混乱。

## 2. 主题驱动改写（不是 1:1 抄）

wiki 不是 sources 的目录索引。wiki 是**"如果你忘了原文也能看懂的"主题汇总**。

| ❌ 反 pattern | ✅ 正确做法 |
|---|---|
| 按原文章节抄一遍，标题翻译一下 | 拆"概念 / 心法 / 案例 / 反例 / 何时用"，跨原文重组 |
| 1 source = 1 wiki 机械映射 | 多份合一 / 一份拆多 |
| 留下"第三章讲了……"的引用 | 直接给结论 + Why，引用原文用 frontmatter sources |
| 复制原文超过 3 句 | 改写或用 `>` 引用块 + 标来源 |

**自检 3 项**：
- 删 source，wiki 仍能自包含读懂
- 每节都有 Why（动机/踩坑/案例/数据）
- Agent 凭 frontmatter.description 一行决定要不要打开

**为什么这条最重要？** 因为如果你的 wiki 是"原文的搬运"，3 年后 Claude 给你召回的是垃圾。整个系统就废了。这是唯一**不可降级**的原则。

## 3. 7 个固定一级 tag

```
#项目 #方法论 #文档 #主题 #人物 #时间 #状态
```

**为什么固定？** tag 系统最大的失败模式是"无限新建一级 tag" → 6 个月后你有 50 个一级 tag → 搜索体验崩塌。

**为什么是这 7 个？** 跨数百份资料反复迭代出来的最小覆盖集。每个 tag 回答一个不同维度的问题：

| Tag | 回答 |
|---|---|
| `#项目` | 这份资料属于哪个公司/项目/学习源？ |
| `#方法论` | 用了/学了哪个方法论？ |
| `#文档` | 是 PRD / 复盘 / 转写 / 课程笔记 / ……？ |
| `#主题` | 跨项目可复用的概念词（自由）？ |
| `#人物` | 关键作者 / 老板 / 合作方？ |
| `#时间` | 哪段经历 / 哪个 H1H2？ |
| `#状态` | 待 ingest / archived / superseded？ |

**子层完全自由**，按需扩展。Claude 在 ingest 时遇到不存在的子层会先查重（相似度 > 80% 不新增），通过后写进 `tags-vocabulary.md`。

**铁律**：不擅自新增一级。如果你真的发现需要第 8 类，停下来想 1 周，多半发现可以归到现有 7 类的某个子层。

## 4. 双向 frontmatter 回填

每份 source 知道自己被哪些 wiki 引用，反之亦然：

```yaml
# wiki/acme-product-history.md
sources:
  - ../sources/work/acme/2024-08-15-prd-v2.md
  - ../sources/work/acme/2025-01-10-retro.md

# sources/work/acme/2024-08-15-prd-v2.md
ingested_to:
  - ../../wiki/acme-product-history.md
  - ../../wiki/wiki-product-decision-frameworks.md
```

**为什么双向？**

- 写 wiki 时 → 顺着 `sources` 反查原文
- 删/改 source 时 → 顺着 `ingested_to` 知道要修哪些 wiki
- 跑 lint 时 → 双向不一致就是孤岛/断链

**Obsidian 的 backlinks 面板天然显示这个关系**（不用插件）。

## 5. 大原档跟精华同目录共用 slug

```
sources/learning/some-course/
├── 2026-05-11-some-topic.md         ← 精华（进 git）
├── 2026-05-11-some-topic.docx       ← 原档（.gitignore 排除，本地保留）
└── 2026-05-11-some-topic.pdf        ← 同上
```

**为什么这么放？**

- **同 slug** → 你看 `sources/learning/some-course/` 一眼能配对"哪份精华对应哪份原档"
- **同目录** → 不需要维护 `精华/` 和 `原档/` 两套并行结构
- **.gitignore 控制谁进 git** → 你不用每次 ingest 都决定"这份算不算大"

**为什么不删原档？** 因为：
- 精华改写难免漏细节（图表 / 数字 / 上下文）
- 3 年后你可能突然想看原页布局
- 删原档是"永久丢失"，不删只是占本地硬盘（便宜）

**用户的清理节奏（独立于 git）**：你定期看 `sources/` 各目录里的大原档，挑要的传外部存储 / 网盘，传完本地 rm。**Claude 不主动提醒**，是你自己的节奏。

---

## 副原则

这些不上"5 个核心"列表但同样重要：

- **永不 rm wiki 文件**。要弃用 → frontmatter 加 `deprecated: true`，可逆，搜旧概念还能回溯
- **inbox ingest 完必须清空**。这是契约 —— 留在 inbox 的文件 = 未来你不知道"这份处理完了没"
- **跨 wiki 主题合并提议而不擅自合**。Claude 在 Step 8 报告主题交叉机会，等用户拍板走 A/B/C/D 哪条路径
- **PDF 必须分页全读**。不允许"只读关键章节"或"抽样" —— 那是把改写质量赌在 Claude 的瞎猜上
- **英语源建议双语化（保留英文原文 + 加母语翻译）**。不要擅自删英文只留母语 —— 保留原文是为了精度可追溯

## 改这套系统的边界

| 可以改 | 别动 |
|---|---|
| 一级目录数量（4 个 → 加 health / projects / business）| 三段分离 inbox/sources/wiki |
| tags-vocabulary 的子层完全按你的项目重写 | 7 个一级 tag |
| `.gitignore` 的具体扩展名列表 | 大原档跟精华同目录共用 slug |
| SKILL.md 里的 Step 顺序 / 报告模板措辞 | 双向回填 frontmatter |
| 加新 skill（lint / archive / translate / publish） | 主题驱动改写 |

简言之：**结构骨架别动，肉自己长**。
