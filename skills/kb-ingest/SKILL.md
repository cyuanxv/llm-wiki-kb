---
name: kb-ingest
description: 把 ~/kb/inbox/ 下的原始资料消化、改写成 ~/kb/wiki/ 下的结构化 wiki + 归档到 sources/。触发场景：用户说 "ingest 这批" / "处理 inbox" / "消化新资料" / "kb 收一下" / "把 inbox 里的东西整理一下"。不适用：① 直接抓网页（走对应抓取工具）② 写到 Claude memory（物理分离，不是 kb 的事）
---

# kb-ingest：inbox → sources + wiki

## 你是谁

你是用户的 kb 消化助手。用户把原始资料（md/txt/pdf/转写文本/截图/导出 PDF 等）拷进 `~/kb/inbox/`，你的工作：

1. 读懂内容
2. 决定 area / project / doc_type / 嵌套 tags
3. 主题驱动改写成 wiki（更新现有 / 新建）
4. 原子归档 + 双向回填 frontmatter + commit

规则书：`~/kb/SCHEMA.md`（必读，里面定义了 7 个一级 tag、frontmatter 规范、目录约定等）。

## 为谁写（wiki 读者画像）

wiki 的读者**只有一个人：未来的你自己**。改写时一直对着这个画像写：

- **聪明的外行**：未来的你早忘了今天读的细节 —— 不要写小白教程，但遇到专业术语（jargon）必须用括号或一句话点破，别假定还记得行话
- **类比 > 抽象**：能用日常类比（"图书馆的卡片目录"）说清的，别堆术语（"B-tree 索引"）
- **决策导向**：未来的你来查 wiki 是为了"下次遇到 X 该怎么办"，不是为了"重学一遍学科" —— 所以 Why / 何时用 / 反例 比 What 更值钱

> 如果你给自己定过语气 / 身份偏好（例如记在 Claude memory 或某份 profile 里），改写遇到术语时回想它来决定要不要展开解释。

## 前置 Read（每次必跑）

```
Read ~/kb/SCHEMA.md             # 规则
Read ~/kb/INDEX.md              # 已有 wiki 总览
Read ~/kb/tags-vocabulary.md    # tag 真理来源
Read ~/kb/external-media.md     # 大原档索引（看是否要更新）
Glob ~/kb/inbox/*.*             # 列待处理
Glob ~/kb/wiki/*.md             # 列候选 wiki（读标题/description）
```

## 单份 raw 的处理

### Step 1：探测格式

| 格式 | 处理 |
|---|---|
| `.md/.txt/.csv/.json` | 直接 Read |
| `.pdf`（< 50 页） | 直接 Read 整本 |
| `.pdf`（≥ 50 页） | 报告"N 页，预计 X 分钟"，等用户点头后**分页全读** |
| `.png/.jpg` | 图像理解读 |
| `.pptx/.docx` 原档 | **读不了** → 写 `<文件名>.review.md` 说明"请导出 PDF 后重 ingest" |
| `.psd/.fig/.sketch/.ai` | **读不了** → 写 review.md "请导出关键页 PNG 放 .assets/" |
| `.mp4/.mov/.mp3/.wav` | **读不了** → 写 review.md "请先转写成 .md" |
| 其他 | review.md 询问处理方式 |

### Step 2：去重检查

```
对每份新文件：
  a. 算文件 hash + 读首段 200 字 + title
  b. Grep sources/ 看有没有相同 hash / 高度相似的 title
  c. 命中 → 走更新流程（Step 5 决策树指向已有 wiki）
  d. 高度相似但不确定 → 留 inbox + 写 review.md
```

### Step 3：PDF 分页全读铁律

```
totalPages = 探测 PDF 总页数
if totalPages ≥ 50:
    报告 "N 页，预计 X 分钟"，等用户确认
分页循环：
    for batch in [(1,20), (21,40), ...]:
        text = Read(pdf, pages=batch)
        累积摘要（防 context 爆）
        记关键概念清单
全部读完后基于完整累积理解改写
wiki frontmatter 标注 ingest_quality: full_scan, pages_read: N/N
```

**铁律：**
- ❌ 不允许只读前 N 页就改写
- ❌ 不允许"只读关键章节"或"摘要式"
- ❌ 不允许抽样
- ✅ 必须分页全读

### Step 3.5：元数据交叉校对（防 OCR / 字幕错拼）

**OCR、字幕、转写都会错拼专有名词**（人名 / 公司 / 技术词尤其严重）。改写前**先扫元数据，把它当权威拼写源**：

| 源类型 | 权威拼写源 |
|---|---|
| PDF | 封面标题、目录页、版权页、作者署名 |
| docx | 封面、章节大标题、页眉 / 页脚 |
| YouTube 转写 | 视频标题、视频描述、频道名 |
| 公众号文章 | 公众号名、作者署名、文末原文链接 slug |
| 聊天记录导出 | username / display name（不是聊天里别人随口叫的昵称） |
| 课程录音转写 | 课程封面、PPT 标题、讲师介绍页 |

**操作：**
1. 扫元数据，列出权威拼写的人名 / 公司 / 技术词清单
2. 改写时遇到正文里这些词的疑似变体，**以元数据为准修正**
3. 不确定时：留原文 + 加 `<!-- TODO 拼写存疑 -->` 注释，等你本人确认

**为什么单列一步**：一段课程录音转写里，同一个讲师的名字常被识别成三四种拼法；统一以课程封面署名为准，召回时才不会因为拼错而搜不到。

### Step 4：分类决策

读 `tags-vocabulary.md`，然后决定：

| 字段 | 怎么定 |
|---|---|
| `area` | 看内容判断：work / learning / life / reference |
| `project` | 二级目录（work 下是公司/项目，learning 下是学习源）。life 下常空 |
| `doc_type` | PRD / 复盘 / 会议纪要 / 转写 / 行业报告 / 课程笔记 / … |
| `domain` | 自由文字，**优先复用已有**（grep sources frontmatter 看 domain 重名） |
| `tags` | 嵌套式，优先从 vocabulary 选；新增前查重（相似度 > 80% 不新增） |

**铁律：**
- 一级 tag **只能从 7 个里选**：`#项目 #方法论 #文档 #主题 #人物 #时间 #状态`
- **不允许**擅自新增一级 tag

### Step 5：决策树（更新 / 新建 wiki）

```
- 命中现有 wiki（标题/tags 重合 > 60%） → 更新
- 不命中 → 新建
- 跨多主题 → 新建多个，INDEX 加分类
```

**铁律：更新优先于新建。要新建必须能回答"为什么不能合到 wiki-X"。**

### Step 6：主题驱动改写

| ❌ 不要 | ✅ 要 |
|---|---|
| 按原文章节抄一遍 | 拆"概念 / 心法 / 案例 / 反例 / 何时用"，跨原文重组 |
| 1 source = 1 wiki 机械映射 | 多份合一 / 一份拆多 |
| 留下"第三章讲了……"的引用 | 直接给结论 + Why，引用原文用 frontmatter sources |
| 复制原文超过 3 句 | 改写或用 `>` 引用 + 标来源 |

**自检 3 项：**
- [ ] 删 source，wiki 仍能自包含读懂
- [ ] 每节都有 Why（动机/踩坑/案例/数据）
- [ ] Agent 凭 frontmatter.description 一行决定要不要打开

**英语源建议双语化**（见 `~/kb/SCHEMA.md` "双语翻译规则"节）：

- 主要原文是英文 → 改写时**同时做翻译**（不要分两次跑）
- 长引用块：`> "原文"` 下方加 `> *译：中文*`
- 加粗英文短句：`**"原文"**（中文）`
- 表格英文列：单元格内 `原文<br>*译：中文*`
- 专有名词：首次出现 `Foo（中文释义）`，后续不重复
- 不翻：章节标题 / 产品名 / 人名 / 已经中文化的部分
- frontmatter 加 `translation_status: bilingual`（已完成）/ `partial`（部分，需在 wiki 末尾列 TODO）/ `not_applicable`（中文/原生语言）
- ❌ 不擅自删英文只留中文 — 保留原文是为了精度可追溯

### Step 7：决定标准化文件名

`YYYY-MM-DD-area-project-slug.md`，如 `2024-08-15-acme-product-prd-v2.md`。

如果用户已经命名得好（有日期、有关键词），保留原名，只补缺失部分。

### Step 8：报告完整计划给用户（批量时一次报全）

**Step 8 必含两部分**：① 每份文件的归档计划 ② 跨 wiki 主题合并机会扫描

```
## 部分一：归档计划

1. inbox/foo.pdf（87 页, 45MB）
   → sources/work/acme/2024-08-15-acme-product-prd-v2.md（精华版）
   + 更新 wiki/acme-product-history.md（merge 2 段新内容）
   + 大原档保留本地：sources/work/acme/2024-08-15-acme-product-prd-v2.pdf（被 .gitignore 排除，不进 git）
   + external-media.md 加 1 行（如有外部存储路径）
   tags: 项目/acme/会员, 文档/PRD, 主题/等级体系

2. inbox/bar.md（2KB）
   → sources/learning/some-course/2026-05-15-topic-x.md（直接归档）
   + 更新 wiki/some-course-topic-x.md（小节 v2）
   tags: 方法论/some-course/topic-x, 文档/课程笔记

3. inbox/baz.png
   → 不确定归哪个 area，留 review.md 等用户回答

## 部分二：跨 wiki 主题合并机会（必扫，无则明确写"本批无"）

提取本批核心主题 → Grep wiki/*.md frontmatter + 章节 → 命中 ≥ 2 个跨作者 wiki：

机会 A：<主题名>
  - 已有：wiki/<source-a>-<topic>.md / wiki/<source-b>-<topic>.md
  - 本批新增：<source-c>-<topic>.md（<新视角>）
  - 建议路径：B（默认）— 新建 wiki-<主题>.md，3 个旧 wiki 保留 + 加 related 反指
  - 你的选择：做 B / 改走 A 只关联 / 改走 C 旧 wiki deprecated / 改走 D 并入某个旧 wiki / 暂缓 / 永不

机会 B：（若有则列，无则跳过）

确认执行（归档计划 + 主题合并选择）？
```

**主题扫描怎么做**：

1. 从本批内容提取 2-5 个核心关键词（技术栈名 / 方法论名 / 行业概念）
2. `Grep -l "关键词" wiki/*.md` 找命中的 wiki
3. 过滤掉同一作者/同一 project 的（那是作者内部主题，合了反而丢上下文）
4. 剩 ≥ 2 个跨作者命中 → 触发机会报告
5. 详细判断标准见 `~/kb/SCHEMA.md` "跨 wiki 主题整合"节

**铁律**：不擅自合并 — 只能"提议 + 等拍板"。用户说"做"才合，说"暂缓"留待下次，说"永不"在 wiki frontmatter 加 `merge_skip: <主题>` 标记。

### Step 9：原子执行（用户点头后）

**核心约定：精华 .md 和原档（任何格式）都放在 `sources/<area>/<project>/` 同目录，共用同 slug，只是扩展名不同。**

```
对每份（批量时按顺序）：
  a. 写精华到 sources/<area>/<project>/<标准化 slug>.md
     - .md/.txt/.csv 等小文本原档：也可以同时 mv 过去保留（同 slug 不同扩展）
     - .pdf < 5MB：同上，mv 过去保留
     - .docx/.pptx/.xlsx/.psd/.mp4/...：同上，mv 过去保留
       （这些会被 .gitignore 排除，本地保留供用户未来选择性上传外部存储）
  b. mv 原档 inbox/xxx.<原扩展> → sources/<area>/<project>/<标准化 slug>.<原扩展>
     - 注意：不是 git mv（因为大原档要被 ignore，git 不该跟踪）
     - 用 mv，然后让 .gitignore 自动决定是否跟踪
  c. Write 或 Edit wiki/<wiki 名>.md
     - 已有 wiki：必须先 Read → 生成 diff 给用户看 → 用户点头才落盘
     - 标 <!-- manual-edit: keep --> 的段落绕开，不动
  d. 双向回填 frontmatter：
     - source.ingested_to += wiki 路径
     - wiki.sources += source 路径
  e. 更新 INDEX.md（新建 wiki 时）
  f. 更新 external-media.md（大原档时，登记"已落在 sources，等待外部备份"）
  g. 更新 tags-vocabulary.md（新子层 tag 时）
  h. inbox 清空（原档全 mv 走了，inbox 应该不剩文件）
最后：
  cd ~/kb && git add -A && git commit -m "ingest: <source 简称> → <wiki 名>" && git push
```

**push 失败处理：**
- commit 已落本地，数据不丢
- 报告用户具体错误（网络 / auth / 冲突），让 ta 手动 `git push` 或先 `git pull --rebase`
- 不要 `--force` push（覆盖远程历史的代价太高）
- 如果用户没配 remote，跳过 push，提示一次即可（不每次都提醒）

**绝对不做：**
- ❌ `rm inbox/xxx.docx`（永远丢了原档）
- ❌ 把原档挪到 inbox 外的其他目录（如 .staging/）— 增加位置一致性问题
- ❌ 留原档在 inbox（违反"ingest 完 inbox 必须清空"约定）
- ❌ 用 git mv 大二进制（应该用 mv，gitignore 自然处理）

### Step 10：验证

- 所有相对路径文件确实存在（`ls`）
- frontmatter yaml 合法
- INDEX 新条目可定位
- inbox 该清的清了
- `git status` 干净
- `git log @{u}..` 为空（本地已 push 到 origin/main，若有 remote）

## Inbox 上限

- inbox 文件数 < 10：正常处理
- inbox 文件数 ≥ 10：开始处理前提醒用户"inbox 已 N 份，建议先清"
- inbox 文件数 ≥ 30：**强烈建议先走轻量归档**（只挪不改写）减负

## 反 pattern（绝对不做）

- ❌ 把原文整段塞进 wiki，只改标题
- ❌ 1 source = 1 wiki 机械映射
- ❌ 新建 wiki 不更新 INDEX
- ❌ 改写丢 Why / 数字 / 案例
- ❌ 写到 Claude memory 目录（kb 跟 memory 物理分离）
- ❌ 擅自新增一级 tag
- ❌ 跳过 PDF 末尾页数
- ❌ 覆盖 `<!-- manual-edit: keep -->` 段落
- ❌ 跨多 source 改写但不在 frontmatter.sources 全列出
- ❌ 删原档（原档要 mv 到 sources/ 同目录跟精华做伴，用户自己决定何时删；不是 Claude 决定何时删）

## 何时停下问

- 内容自相矛盾（可能 source 抓取出错）
- 找不到合适现有 wiki 也不确定新建名
- 改写要删现有 wiki > 30% 内容
- 想新增一级 tag（只有 7 个，不能扩，要用户拍板）
- 不确定文件归哪个 area（写 review.md）
- 大 PDF 全读会消耗大量 token，先报告等用户确认
