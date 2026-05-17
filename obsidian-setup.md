# Obsidian Companion 配置

`~/kb/` 是纯 markdown 仓库，可以用任何编辑器。**Obsidian + Dataview** 是最贴合本系统的可视化方案：

| 你的 kb 设计 | Obsidian 自带能力 |
|---|---|
| `wiki/` + `sources/` 双层 | Vault 直接指向 `~/kb/`，目录树天然分层 |
| 7 个一级 + 嵌套子层 tag | Tag 面板支持嵌套展开 |
| frontmatter 双向回填（`sources` / `related` / `ingested_to`） | Backlinks / Outgoing Links 面板自动反查 |
| INDEX.md 手维护 | **Dataview 插件**自动生成视图，告别手维护 |
| 跨 wiki 主题关联 | Graph View 可视化聚簇 / 孤岛 |

## 安装（5 分钟）

### 1. 装 Obsidian

→ https://obsidian.md （macOS / Windows / Linux 都有，个人免费）

### 2. Open Vault → 选 `~/kb/`

打开 Obsidian → "Open folder as vault" → 选你的 kb 路径。

### 3. **关键：关闭 wikilinks，强制用标准 markdown 链接**

设置 → 文件与链接：

| 选项 | 设成 |
|---|---|
| 使用 `[[Wikilinks]]` | **关闭** |
| 新链接格式 | **相对路径** |
| 自动更新内部链接 | 开 |

**为什么必须关 wikilinks**：本 kb 系统所有链接都用标准 `[text](./path.md)` 格式（兼容 GitHub / VSCode / 任何 markdown 工具）。Obsidian 默认偏爱 `[[wiki-name]]` 简写，但这种链接在没有 Obsidian 的环境里渲染成纯文本死链。**关掉它**，强制 Obsidian 也用标准格式。

### 4. 装 Dataview 插件

设置 → 第三方插件 → 关闭"安全模式" → 浏览 → 搜 "Dataview" → 安装 + 启用。

## Dataview 查询模板

在 wiki 或 sources 里建一个 `dashboards/` 目录（不算 wiki，只是仪表盘）：

```bash
mkdir -p ~/kb/dashboards
```

下面几份直接复制粘贴。

### Dashboard 1：待 ingest 清单

`~/kb/dashboards/待-ingest.md`：

````markdown
# 待 ingest 队列

> 所有 sources/ 下 status=待 ingest 的文件。下次跑 /kb-ingest 优先处理。

```dataview
TABLE
  area,
  project,
  doc_type,
  captured_at
FROM "sources"
WHERE contains(string(file.frontmatter.tags), "状态/待 ingest")
   OR file.frontmatter.status = "待 ingest"
SORT captured_at DESC
```
````

### Dashboard 2：30 天没 lint 的 wiki

`~/kb/dashboards/过期-wiki.md`：

````markdown
# 长时未 lint 的 wiki

> last_lint 超过 30 天的 wiki，可能信息过时。

```dataview
TABLE
  last_lint,
  date(today) - date(last_lint) as "几天没 lint"
FROM "wiki"
WHERE last_lint AND (date(today) - date(last_lint)).days > 30
SORT (date(today) - date(last_lint)).days DESC
```
````

### Dashboard 3：按 area 分组的 wiki 总览

`~/kb/dashboards/wiki-总览.md`：

````markdown
# Wiki 总览（按 area 分组）

```dataview
TABLE
  description,
  length(sources) as "sources 数",
  updated
FROM "wiki"
WHERE area
GROUP BY area
SORT updated DESC
```
````

### Dashboard 4：孤岛 wiki（没在 INDEX 也没被引用）

`~/kb/dashboards/孤岛-wiki.md`：

````markdown
# 可能的孤岛 wiki

> 既不在 INDEX 也没被其他 wiki 的 related 字段引用 — 可能是新建忘了更新索引。

```dataview
LIST
FROM "wiki"
WHERE !contains(file.inlinks, "INDEX")
SORT file.mtime DESC
```

> 注：这个粗略检测可能误报。结合 grep `grep -L "wiki-name.md" wiki/*.md INDEX.md` 验证。
````

### Dashboard 5：tag 子层使用频次

`~/kb/dashboards/tag-频次.md`：

````markdown
# Tag 使用频次

```dataview
TABLE length(rows) as "用了 N 份"
FROM "sources" or "wiki"
FLATTEN file.tags as tag
WHERE tag
GROUP BY tag
SORT length(rows) DESC
LIMIT 50
```

> 用 1 次的 tag = 孤儿（可能拼写错误或同义，跑 lint 时考虑合并）
````

## Obsidian 用法速查

| 操作 | 快捷键（默认） |
|---|---|
| 快速打开任何文件 | `Cmd+O` / `Ctrl+O` |
| 全文搜索 | `Cmd+Shift+F` / `Ctrl+Shift+F` |
| Tag 面板 | 左侧 Tag 图标 |
| Graph View | 左侧图标 / `Cmd+G` |
| Backlinks 面板 | 右侧 |

**Graph View 用法**：调过滤把"sources/"目录隐藏，只看 wiki 之间的关系图 → 一眼能看到哪些 wiki 是孤岛、哪些是密集主题簇。

## 跟 git 的关系

Obsidian 的配置目录 `.obsidian/` 已经在 `.gitignore` 里了（每台机器配置不同，不该同步）。

如果你想多设备共享 Obsidian 配置，新建 `.obsidian-shared/` 手工管，或用 Obsidian Sync（付费）。

## 选不选 Obsidian？

| 用 Obsidian | 不用，纯 CLI/编辑器 |
|---|---|
| 喜欢可视化、tag 面板、graph view | 喜欢命令行，习惯 grep + vim/vscode |
| 想用 Dataview 做仪表盘 | 不需要仪表盘，靠 git log + grep 够用 |
| 平时也写日记 / 个人笔记 | 只把 kb 当 LLM 的 RAG-replacement，不自己看 |
| 多设备同步用 iCloud / Obsidian Sync | 只在一台机器用 |

两种都行。系统设计上是编辑器无关的。
