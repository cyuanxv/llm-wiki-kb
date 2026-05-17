# EXAMPLE — 5 分钟跑通：一份 PDF 从 inbox 到 wiki

跟着做一遍，理解 `/kb-ingest` 在做什么。

## 场景

假设你刚读了一份"如何做产品决策"的 30 页 PDF（任何来源都行），想存进 kb 给未来的你查。

## Step 0：准备

```bash
# 确认 init 跑完了
ls ~/kb/
# README.md  SCHEMA.md  INDEX.md  tags-vocabulary.md  external-media.md
# inbox/  sources/  wiki/
```

## Step 1：把 PDF 扔进 inbox

```bash
cp ~/Downloads/product-decision-frameworks.pdf ~/kb/inbox/
```

不用整理，不用分类，**扁平投递**。文件名也不用改（Claude 会标准化）。

## Step 2：开 Claude Code，让它 ingest

```bash
cd ~/kb  # 或任何目录
claude
```

然后跟 Claude 说：

```
> ingest 一下
```

Claude 触发 `/kb-ingest` skill。你会看到（示意）：

```
[Read ~/kb/SCHEMA.md]
[Read ~/kb/INDEX.md]
[Read ~/kb/tags-vocabulary.md]
[Read ~/kb/external-media.md]
[Glob ~/kb/inbox/*.*]

📥 检测到 1 份待处理：
  - inbox/product-decision-frameworks.pdf (30 页, 2.3 MB)

正在分页全读……
[Read pdf pages 1-20]
[Read pdf pages 21-30]

✓ 完整读完 30/30 页
```

## Step 3：Claude 报告归档计划

```
## 归档计划

1. inbox/product-decision-frameworks.pdf（30 页）
   → sources/learning/some-source/2026-05-18-product-decision-frameworks.md（精华版）
   + sources/learning/some-source/2026-05-18-product-decision-frameworks.pdf（原档，gitignored）
   + 新建 wiki/product-decision-frameworks.md
   tags:
     - 项目/<待你确认>
     - 文档/课程笔记
     - 主题/决策
     - 主题/产品

frontmatter:
  area: learning
  project: some-source（请确认或改）
  doc_type: 课程笔记
  domain: 产品决策

## 跨 wiki 主题合并机会

本批主题："产品决策" / "决策框架"
扫描 wiki/ → **本批无跨 wiki 合并机会**（这是第一份）

## 待澄清

- 这份 PDF 的作者 / 来源是？我看到引用了 Lenny / Marty Cagan 等
  - 影响 project 字段（如 lenny / svpg / generic）

确认归档（要不要改 project / area / tags）？
```

## Step 4：你回答 + 确认

```
> 作者是 Marty Cagan，project 改成 svpg。其他都对，开干。
```

Claude 执行：

```
[Write sources/learning/svpg/2026-05-18-product-decision-frameworks.md]
[mv inbox/product-decision-frameworks.pdf → sources/learning/svpg/...]
[Write wiki/product-decision-frameworks.md]
[Edit ~/kb/INDEX.md] +1 行索引
[Edit ~/kb/tags-vocabulary.md] +"项目/svpg" 子层
[Bash: cd ~/kb && git add -A && git commit -m "ingest: svpg product decision frameworks → wiki/..."]

✓ 完成。inbox 已清空。
  - sources/learning/svpg/2026-05-18-product-decision-frameworks.md
  - sources/learning/svpg/2026-05-18-product-decision-frameworks.pdf (gitignored)
  - wiki/product-decision-frameworks.md (新建)
  - INDEX + tags-vocabulary 更新
  - git commit: abc1234
```

## Step 5：看产物

```bash
cat ~/kb/wiki/product-decision-frameworks.md
```

你会看到 Claude 写的 wiki：**不是抄 PDF**，而是按"概念 / 心法 / 案例 / 何时用"主题驱动重组的笔记，每节带 Why。frontmatter 链回 source。

```bash
cat ~/kb/sources/learning/svpg/2026-05-18-product-decision-frameworks.md
```

精华版 source：保留 PDF 关键章节摘要 + 数据 + 引言，比 wiki 更接近原文。

```bash
ls ~/kb/sources/learning/svpg/
# 2026-05-18-product-decision-frameworks.md
# 2026-05-18-product-decision-frameworks.pdf
```

精华 + 原档同目录共用 slug。原档被 .gitignore 排除，本地保留。

## Step 6：3 个月后召回

某天你在做产品决策，跟 Claude 说：

```
> 我在纠结要不要做某个 feature，有没有什么决策框架可以参考
```

Claude：

```
[Read ~/kb/INDEX.md]
[Grep wiki/ "决策"]
[Read wiki/product-decision-frameworks.md]

根据你之前 ingest 过的 SVPG / Marty Cagan《产品决策框架》……
[直接给你框架 + Why + 例子]
```

**关键**：Claude 没有读 30 页 PDF，只读了你的 wiki（几百行）。这就是为什么 wiki 必须**主题驱动 + 自包含**——它是给"未来的你 + 未来的 Claude"看的。

## 进阶：第二份资料引发主题合并

假设你过几天又 ingest 了一份 Lenny 访谈，主题也涉及"产品决策"。

```
> ingest 一下
```

Claude 会在 Step 8 报告里多一段：

```
## 跨 wiki 主题合并机会

主题"产品决策框架"：
  - 已有：wiki/product-decision-frameworks.md（SVPG / Marty Cagan 视角）
  - 本批新增：lenny-podcast-product-decisions.md（Lenny 访谈视角，本批新写）

建议路径：B（默认）
  - 新建 wiki-product-decision-meta.md（跨作者概念骨架 + 各家 Why 对比）
  - 两个旧 wiki 保留（各有独家案例）
  - 加 related 反指主题 wiki

你的选择：
  - B（默认）做
  - A 只加 related 互链，不新建主题 wiki
  - C 新建主题 wiki + 旧 wiki 标 deprecated
  - D 内容并入其中一个旧 wiki
  - 暂缓 / 永不
```

这就是**跨 wiki 主题整合**机制 —— 防止你的 kb 长出几十个孤立的"按作者组织"的 wiki，让真正的"主题汇总"逐步浮现。

---

## 关键直觉

跑完一次后你应该理解：

| 你做的 | Claude 做的 | 系统得到的 |
|---|---|---|
| 扔文件进 inbox | 读 + 分类 + 改写 + 归档 + commit | 一份精华 source + 一份主题驱动 wiki |
| 自然语言问问题 | Read INDEX → Grep wiki → 读匹配 wiki | 30 秒精准召回 |
| 定期再扔新资料 | 检测主题交叉 + 提议跨 wiki 合并 | wiki 体系逐步聚簇 |
| 每月扫一次 | （需自己实现 lint 或让 Claude 扫） | 断链 / 孤岛 / tag 漂移 报告 |

**你的工作**：投递 + 拍板（合并选哪条路径）+ 偶尔手工 lint。
**Claude 的工作**：所有读 + 写 + 改写 + 链接维护。

这就是 Karpathy LLM Wiki Pattern 的核心：**人做判断，LLM 做苦力**。
