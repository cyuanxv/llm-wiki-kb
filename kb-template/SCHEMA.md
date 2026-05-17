---
name: kb-schema
title: KB 规则书
description: Ingest / Query / Lint 操作规则、文件结构、frontmatter 规范、嵌套 tag、大文件流程
type: schema
last_lint: null
---

# KB 规则书（Karpathy LLM Wiki Pattern）

## 三层架构

```
Layer 3: SCHEMA（本文件）
   定义规则：Ingest / Query / Lint 怎么跑
        ▲
Layer 2: WIKI（~/kb/wiki/）
   LLM 主战场。改写后的结构化笔记。主题驱动、自包含、每节带 Why
        ▲
Layer 1: SOURCES（~/kb/sources/）
   档案库。原始资料的精华文档 + 小附件。
   大原档（视频/PSD/大 PDF）本地保留（被 .gitignore 排除），可选择性同步到外部存储
        ▲
Inbox （~/kb/inbox/）
   你扁平投递，Claude /kb-ingest 处理
```

## 目录结构

一级目录稳定 4 个，几年不动：

```
sources/
├── work/        # 工作经历（公司/学校/团队级项目）
│   ├── <project-1>/ <project-2>/ ...    # 二级：自然分组
├── learning/    # 课程 / 学习
│   ├── <course-or-source-a>/ <course-or-source-b>/ ...
├── life/        # 兜底层：生活/家庭/兴趣/健康/财务/育儿
└── reference/   # 行业报告 / 公共知识 / 通用资料
```

**规则**：三级及以下**不再建目录**，用 frontmatter 字段 + tags 表达细分类。`life/` 兜底层某 domain 积累 > 20 份时，可考虑独立成新的一级目录（lint 工具会提醒）。

## Frontmatter 规范

### source 文件

```yaml
---
# 基本
name: 2024-08-15-acme-product-prd-v2
title: Acme 产品 PRD v2
type: source
captured_at: 2024-08-15

# 结构字段（精确筛用）
area: work                  # work / learning / life / reference，必填
project: acme               # 二级目录名，必填
domain: 产品中心-会员业务    # 自由文字，优先复用已有
initiative: 会员等级专项     # 可选
doc_type: PRD               # PRD / 复盘 / 会议纪要 / 转写 / 行业报告 / ...

# Tags（嵌套式，Obsidian 面板浏览用）
tags:
  - 项目/acme/会员
  - 项目/acme/V2-2024
  - 文档/PRD
  - 主题/等级体系

# 大原档外部引用（如有外部备份位置，可选）
source_external:
  provider: <cloud-storage-name>
  path: /work/acme/2024-08-15-prd-v2.pdf
  size: 45MB
  pages: 87
  ingest_quality: full_scan
  ingested_at: 2024-08-15

# 反向指针（ingest 时回填）
ingested_to:
  - ../../wiki/acme-product-history.md
---
```

### wiki 文件

```yaml
---
name: acme-product-history
title: Acme 产品演化史
description: 从 v1 到 v3 的关键节点 + 决策 Why
type: wiki
area: work
tags:
  - 项目/acme
  - 文档/方法论
  - 主题/产品演化
sources:
  - ../sources/work/acme/2024-08-15-acme-product-prd-v2.md
related:
  - ./acme-team-decisions.md
created: 2026-05-15
updated: 2026-05-16
last_lint: 2026-05-16
expires: null
---
```

## 嵌套 Tags（一级 7 个，固定）

| 一级 tag | 含义 | 子层示例 |
|---|---|---|
| `#项目` | 资料属于哪个项目/公司 | `项目/acme/会员` |
| `#方法论` | 用了/学的哪个方法论 | `方法论/some-framework/sub-topic` |
| `#文档` | 文档类型 | `文档/PRD`、`文档/复盘`、`文档/转写` |
| `#主题` | 自由主题词 | `主题/等级体系` |
| `#人物` | 关键人物 | `人物/<name>` |
| `#时间` | 关键时间锚点 | `时间/2024-H2`、`时间/<某段经历>` |
| `#状态` | 文件生命周期 | `状态/待 ingest`、`状态/archived` |

**铁律**：一级 tag **不能擅自新增**。要加得用户拍板，涉及面太广。

**为什么固定 7 个**：tag 系统最大的失败模式是"无限新建一级 tag"导致体系崩塌。把表达自由度推到"子层无限"，但一级强约束。新接触本系统的人最容易忍不住开新一级 tag，请先按现有 7 个用一段时间再说。

## Wiki 可视化：Mermaid（可选）

wiki/*.md 里可以嵌 Mermaid 代码块来表达**纯文本/表格扛不住**的关系：决策树 / 流程 / 状态机 / 时间线 / 思维导图 / 风险-收益散点。Obsidian 和 GitHub 都原生 render，不需要额外工具。

**何时用 Mermaid：**

| 内容形态 | 用什么 |
|---|---|
| 排比列表（规则、要点、checklist） | markdown list |
| 多字段对照表（2-5 列） | markdown table |
| **进度/流程/演化**（A → B → C） | **Mermaid `graph LR`** |
| **决策树**（if/else 分支） | **Mermaid `graph TD`** |
| **2D 对比**（风险 × 收益） | **Mermaid `quadrantChart`** |
| **思维发散**（主题中心+辐射） | **Mermaid `mindmap`** |
| **时间线** | **Mermaid `timeline` 或 `gantt`** |

**铁律：**
- ❌ 不要为了"好看"硬塞 Mermaid。如果一段 markdown 表格已经讲清楚，就不要叠加图
- ❌ Mermaid **不替代**详细表格 — 图给"一眼看出关系"，表格给"精确数据"。两者互补
- ✅ Mermaid 代码块写在对应小节内，跟表格上下相邻
- ✅ Obsidian 没 render → 检查 Mermaid 语法，常见坑：节点 ID 不能含中文/空格（用 `L1["中文标签"]` 这种 ID+label 形式）

## 三个核心操作

### Ingest（写入）

完整流程见 `~/.claude/skills/kb-ingest/SKILL.md`。要点：

1. **去重** — hash + title 比对，命中走更新
2. **分类决策** — Claude 判断 area/project/doc_type，tags 从 vocabulary 选
3. **改写主题驱动** — 不复制原文超 3 句，每节带 Why
4. **PDF 分页全读** — 200 页也读完，不抽样
5. **原子归档** — `git mv inbox/x → sources/.../标准化名`，双向回填 frontmatter，commit
6. **大原档保留本地** — .gitignore 排除大二进制，frontmatter 引用其外部备份路径（可选）
7. **跨 wiki 主题合并检测** — Step 8 报告必须扫主题交叉，主动提议横向整合（详见下节）

### 跨 wiki 主题整合（Step 8 必报项）

**问题**：很多 wiki 是按来源/作者组织（`<source-a>-<topic>` / `<source-b>-<topic>`），但不同作者常分享同领域内容。这些**跨作者的同主题**散在多个 wiki 孤岛里。

**规则**：每次 Ingest 在 Step 8 报告时，必须做一次主题交叉扫描：

```
1. 提取本批新内容的核心主题（2-5 个关键词）
2. 对每个主题：Grep wiki/*.md 的 frontmatter description + tags + 章节标题
3. 命中 ≥ 2 个跨作者 wiki（且非同 project） → 触发"主题合并候选"
4. 在 Step 8 报告里**单独列出** "跨 wiki 主题合并机会" 一节，格式：

   主题 X：<wiki-a>.md + <wiki-b>.md + 本批新内容 三处提及
   → 建议抽出 wiki-<主题>.md（主题汇总，跨作者概念骨架）
   → 原作者 wiki 保留（作者特色 + 原始案例）
   → 等用户拍板"做 / 暂缓 / 永不"
```

**4 种处理路径**（Step 8 提议时必须指明走哪条，默认 B）：

| 路径 | 怎么做 | 适用 | 旧 wiki 怎么办 |
|---|---|---|---|
| **A 只关联** | 各旧 wiki 互加 `related:` 指针，**不新建** | 各家观点已自包含，只缺"知道彼此存在" | 不动 |
| **B 新建主题 wiki + 保留旧 wiki**（默认） | 新 `wiki-<主题>.md` 写跨作者概念骨架 + 各家 Why 对比 | 旧 wiki 各有独家案例 / 视角 / 时间锚 | 不动，只加 `related:` 反指主题 wiki |
| **C 新建主题 wiki + 旧 wiki deprecated** | 新 wiki 写完后，旧 wiki frontmatter 加 `deprecated: true` + `superseded_by:` | 旧 wiki 内容已被完全吸纳，没独家价值 | 标 deprecated，INDEX 移"归档"区，**不删文件**（留历史索引） |
| **D 扩充其中一个旧 wiki** | 内容并入命名最通用的那个旧 wiki | 其中一个旧 wiki 本就接近主题汇总形态 | 被并入的那个标 deprecated |

**何时不合并**：

| 情况 | 原因 |
|---|---|
| 同一作者的多个 wiki 主题相近 | 作者内部已主题驱动改写，合了会丢上下文 |
| 主题相似但目标读者不同 | 如"给 PM 看的 X" vs "给开发者看的 X" |
| 跨 area | work / learning / reference 不互相吸，各自世界 |

**铁律**：
- ❌ 不擅自合并 — 只能"提议 + 等拍板"
- ❌ **永不 rm 任何 wiki 文件** — 最多标 `deprecated: true`（可逆，搜旧概念还能回溯）
- ❌ 不静默替换 — 走 C/D 时必须明示哪个旧 wiki 会标 deprecated，等拍板
- ✅ 默认 B，A/C/D 用户在拍板时指定
- ✅ 主题 wiki 的 frontmatter `sources` 列全所有旧 wiki + 原始 sources
- ✅ 旧 wiki frontmatter 加 `related: [./wiki-<主题>.md]` 反向指向

### 双语翻译规则（英语源 wiki，可选）

**问题**：英语播客、论文、英语博客等改写后 wiki 会留下大量英语引言、专有名词、加粗短句。如果你的母语不是英语，读起来累；但纯翻成中文（或你的母语）又会丢失原始语义精度。

**核心原则**：**保留英文原文（原始精度） + 加母语翻译/释义（可读性）**。

**适用范围**：

| 情况 | 处理 |
|---|---|
| 主要原文是英文（转写 / 论文 / 英语博客） | **建议双语化**，frontmatter `translation_status: bilingual` |
| 中英混排，英文 < 20% | 关键英文短句释义即可，`translation_status: partial` |
| 母语原生 | 不适用，`translation_status: not_applicable` 或省略字段 |
| 已 ingest 但还没翻 | `translation_status: english_only`，留待按需补 |

**翻译四种形态**：

| 形态 | 标记方式 | 示例 |
|---|---|---|
| **长引用块**（整段英文） | 块内追加 `> *译：母语*` 单独一行 | `> "Just do things."`<br>`>`<br>`> *译：说做就做。*` |
| **加粗短句**（口号 / 金句） | 后面括号加母语 | `**"Just do things"**（说做就做）` |
| **表格英文列** | 单元格内 `<br>*译：母语*` 换行 | `\| 原文 <br>*译：母语* \|` |
| **专有名词**（产品 / 人 / 技术） | 首次出现括号注一次，后续不重复 | `Foo（中文释义）` |

**不该翻的**：
- ❌ 章节标题（如果本来就是母语或混排）
- ❌ 产品名 / 品牌名 — 仅首次释义
- ❌ 人名
- ❌ 技术术语短名（API / IDE / CLI / PR — 太常见）
- ❌ 已经在原 markdown 母语化的部分（避免重复翻译）

### Query（读取）

- Claude：`Read INDEX.md → Grep wiki/ → Read 匹配 → 必要时跳 source`
- 你自己（Obsidian）：`Cmd+O` / Tag 面板 / `Cmd+Shift+F`
- 你自己（OS 全文搜）：Spotlight / Windows Search / 等

### Lint（健康检查，可选）

每月一次，跑独立的体检脚本或让 Claude 扫一遍。检查：
- 断链 / 孤岛 wiki / 过期 / 重复 / 未消化 source / frontmatter 错误
- tag 漂移（80% 相似度）/ life 毕业建议 / inbox 堆积 / external-media 一致性

报告写到 `.lint/YYYY-MM-DD-report.md`，**不自动修**，只列清单。

> 本 starter kit 只包含 `kb-ingest` skill。`kb-lint` / `kb-archive` / `kb-translate-cn` 是配套扩展，原作者私人维护，可按需自己实现。

## 大文件流程

### 统一规则

**所有处理完的文件都放在 `sources/<area>/<project>/` 同目录**，同 slug 不同扩展名：

```
sources/learning/some-course/
├── 2026-05-11-some-topic.md         ← 精华（进 git）
├── 2026-05-11-some-topic.docx       ← 原档（不进 git，本地保留）
├── 2026-05-11-some-data.md          ← 精华（进 git）
└── 2026-05-11-some-data.xlsx        ← 数据（进 git，因为 < 1MB 且结构化）
```

**git 跟踪规则（由 .gitignore 控制）：**

| 扩展名 | git？ | 备注 |
|---|---|---|
| `.md` `.txt` `.csv` `.json` | ✅ | 精华文本 |
| `.png` `.jpg` < ~5MB | ✅ | 截图、封面、关键截帧 |
| `.xlsx` | ✅ | 数据集，通常不大 |
| `.pdf` | ✅（默认） | 如果某个 PDF 特别大，手工 ignore |
| `.docx` `.pptx` | ❌ | 一律不进 git（基本都大） |
| `.psd` `.fig` `.sketch` `.ai` | ❌ | 设计稿，基本都大 |
| `.mp4` `.mov` `.mkv` `.mp3` `.wav` `.m4a` | ❌ | 媒体，基本都大 |

**Claude 能读哪些（同 git 跟踪情况无关）：**

| 扩展名 | Claude 读？ |
|---|---|
| `.md` `.txt` `.csv` `.json` | ✅ 直接 |
| `.pdf` | ✅ 分页全读 |
| `.png` `.jpg` | ✅ 图像理解 |
| `.docx` | ✅（via `textutil -convert txt` 提取文本；图片 unzip 后图像理解） |
| `.xlsx` | ✅（unzip + 读 sheet XML） |
| `.pptx` | ❌（导出 PDF 后重 ingest） |
| `.psd` `.fig` `.sketch` `.ai` | ❌（导出关键页 PNG 放 .assets/） |
| `.mp4` `.mov` `.mp3` `.wav` | ❌（先转写成 .md） |

### Ingest 流程（完整）

```
1. 用户把原档投到 inbox/（直接放，可以嵌套子目录）
2. /kb-ingest
3. Claude 读懂内容，分类决策
4. Claude 写精华到 sources/<area>/<project>/<slug>.md
5. Claude 把原档从 inbox/ 挪到 sources/<area>/<project>/<slug>.<原扩展>
   - 精华 .md 和原档同名（slug 一致），只是扩展名不同
   - 大二进制原档被 .gitignore 排除，git 不跟踪，但本地保留
6. inbox 清空 → git commit
```

### 用户的外部备份动作（独立于 git）

`sources/` 就是"待长期归档的清单源"。用户可定期：

1. 找需要长期保留的大原档（.docx / .pptx / .psd / .mp4 / 大 .pdf）
2. 上传到外部云存储（任意网盘 / OSS / NAS）
3. 上传完成后，本地可以 rm 掉原档（精华 .md 还在 git，不丢）
4. 在 `external-media.md` 登记一条（可选）

**Claude 不主动提醒上传**。这是用户自己的节奏。

## 心态条款

见 `README.md`。**ingest 标准 = "未来有可能用一次"**，不限频率。kb 是长期档案，不是高频笔记。
