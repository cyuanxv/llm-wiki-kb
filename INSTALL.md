# INSTALL

## 前置

- macOS / Linux（Windows WSL 也行，原版 Windows 没测）
- [Claude Code](https://claude.com/claude-code) 已安装并能跑
- `git` / `bash` / `zsh` 常规命令行环境

## 3 步安装

### 1. clone repo

```bash
cd ~/Desktop  # 或任何你常放 repo 的位置
git clone https://github.com/<your-username>/kb-starter.git
cd kb-starter
```

### 2. 跑 init.sh

```bash
./init.sh
```

脚本会交互式问：

| 问题 | 默认 | 含义 |
|---|---|---|
| KB 路径？ | `~/kb` | 你的知识库放哪里 |
| git 初始化？ | yes | 在 KB 路径下 `git init` |
| 软链 kb-ingest 到 ~/.claude/skills/？ | yes | 让 Claude Code 能识别这个 skill |
| 配 git remote？ | no（按需） | 推到 GitHub / GitLab 私有 repo |

跑完会显示：

```
✓ KB 已在 /Users/you/kb 初始化
✓ kb-ingest skill 已链接到 ~/.claude/skills/kb-ingest
✓ git 已初始化 + 第一次 commit

下一步：
  1. 打开 Claude Code 进入任意目录
  2. 把一份资料拖进 ~/kb/inbox/
  3. 跟 Claude 说 "ingest 一下"
```

### 3. 第一次 ingest

```bash
# 把一份资料（PDF / md / docx / txt 都行）拷进 inbox
cp ~/Downloads/some-article.pdf ~/kb/inbox/

# 开 Claude Code
cd ~/kb  # 或任何目录都行
claude

# 跟 Claude 说
> ingest 一下
```

Claude 会：
1. Read SCHEMA + INDEX + tags-vocabulary
2. 探测 inbox 里的格式
3. 分页全读 PDF
4. 报告归档计划（哪些字段、归到哪个 wiki、要不要新建）
5. 等你点头
6. 写 wiki/ + 挪 source/ + commit

完整流程见 [EXAMPLE.md](EXAMPLE.md)。

## 推荐 Companion：Obsidian + Dataview

`~/kb/` 是纯 markdown 仓库，可以用任何编辑器。如果你想要**可视化 + 仪表盘**：

```bash
# 1. 装 Obsidian → https://obsidian.md
# 2. Open Vault → 选 ~/kb/
# 3. 设置 → 第三方插件 → 安装 Dataview
# 4. 关闭 wikilinks（设置 → 文件与链接 → 用 [text](path) 而非 [[wikilinks]]）
```

详见 [obsidian-setup.md](obsidian-setup.md)。

## 故障排查

### Claude 说"我不知道 /kb-ingest 是什么"

软链没生效。手动确认：

```bash
ls -la ~/.claude/skills/kb-ingest
# 应该看到 → /<你 clone 的位置>/kb-starter/skills/kb-ingest

# 没看到 → 手动建链
ln -s "$(pwd)/skills/kb-ingest" ~/.claude/skills/kb-ingest
```

Claude Code 启动时扫 `~/.claude/skills/` 加载所有 skill。如果你在跑 Claude Code 时建的链，重启一下。

### Claude 说"读不了 ~/kb/SCHEMA.md"

确认 init 跑完了：

```bash
ls ~/kb/
# 应该看到：README.md / SCHEMA.md / INDEX.md / tags-vocabulary.md / external-media.md / inbox/ / sources/ / wiki/
```

没看到 → 重跑 init.sh，或手动 `cp -r kb-template/* ~/kb/`。

### git push 失败

第一次 commit 后如果你设了 remote：

```bash
cd ~/kb
git remote -v
git push -u origin main
```

GitHub 要求 personal access token 或 ssh key，按 GitHub 自己的文档配。

如果你**不想推到远程**，留 remote 为空也可以，所有变更都在本地 git 里有版本控制。

### 大文件意外进了 git

`.gitignore` 默认排除 .docx / .pptx / .psd / .mp4 等。如果你发现某个大文件进了 git：

```bash
cd ~/kb
git rm --cached path/to/big-file.docx
echo "path/to/big-file.docx" >> .gitignore  # 或调整 .gitignore 规则
git commit -m "fix: remove big file from tracking"
```

### 不想用 Claude Code，能不能换别的 LLM？

理论上可以。`SKILL.md` 是一份纯 markdown prompt，把它塞进任何 LLM 的 system prompt 都能跑。但：
- Claude Code 自带 Read/Write/Edit/Bash 工具，prompt 里的"Read ~/kb/SCHEMA.md"会直接执行
- 其他 LLM 你得自己接工具
- 实测下来 Claude 在长上下文 + 工具调用稳定性上对这套系统体验最好

## 卸载

```bash
rm ~/.claude/skills/kb-ingest  # 移除软链
rm -rf ~/kb                     # 删 KB（注意：里面有你的资料！先备份）
rm -rf <kb-starter clone 路径>  # 删 repo
```
