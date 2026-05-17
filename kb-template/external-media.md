---
name: external-media-index
title: 外部存储原档索引
description: 所有不在本地 git 的原档（视频/PSD/大 PDF/原 PPT）清单。Claude 每次 ingest 大原档时更新本文件
type: schema
last_lint: null
---

# External Media Index

> 所有大原档（> 5MB PDF / 视频 / 音频 / 原 PSD/PPT）的统一索引。本地 git 不存这些文件，只存通过 ingest 改写后的精华 + frontmatter 的 `source_external` 引用。
>
> **可选**：如果你不想把大原档同步到外部存储，这个文件可以一直空着，大原档就放在 `sources/` 同目录（被 .gitignore 排除，本地保留）。

## work

_（待 ingest）_

## learning

_（待 ingest）_

## life

_（待 ingest）_

## reference

_（待 ingest）_

---

## 索引格式约定

每条记录写成：

```markdown
- `/<cloud-storage-path>/<filename>.<ext>`（大小，可选页数）
  - kind: pdf / video / audio / psd / pptx / ...
  - ingested by: ../sources/.../<对应 source.md 的相对路径>
  - local: ../sources/.../<同 slug 不同扩展>（同目录原档，gitignored）
  - captured: YYYY-MM-DD
  - note: 备注（可选）
```

## 维护规则

- Claude `/kb-ingest` 处理大原档时**自动追加**条目到本文件（如果你声明了 source_external）
- 每月 lint 检测：① frontmatter 的 `source_external` 全在本索引（双向一致性）② 外部存储上文件被删/移位时提醒（需用户手工核验，Claude 无法访问外部网盘）
- 用户也可以**手工**编辑本文件，加入"已在外部存储但还没 ingest 的待办原档"清单（放对应分类下）
