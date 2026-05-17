# KB Index

> Agent 入口。查任何 kb 内容时先 Read 本文件，再 Grep `wiki/*.md`。
> 完整规则见 [SCHEMA.md](SCHEMA.md)。
>
> last_lint: null

## work

_（待 ingest）_

> 一级 `work/` 下按公司/项目分二级目录。每个二级目录在本文件加一节。

## learning

_（待 ingest）_

> 一级 `learning/` 下按课程/学习源分二级目录。

## life

_（待 ingest）_

> 兜底层。某 domain（如"健康"、"育儿"）积累 > 20 份时，可考虑独立成新的一级目录。

## reference

_（待 ingest）_

> 行业报告 / 公共知识 / 通用资料。

---

## INDEX 维护约定

- 新建 wiki → `/kb-ingest` 自动加索引条目
- 每条 ≤ 150 字符：`- [wiki-name](wiki/wiki-name.md) — 一句话描述`
- 同 area 下按 project 分节，section title 用 `## <area> / <project>`
- 弃用 wiki（`deprecated: true`）移到末尾 `## 归档` 节，不删文件
