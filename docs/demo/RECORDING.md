# 录 demo gif

README 顶部引用的 gif 路径是 `docs/demo/ingest-demo.gif`。你需要录一段（约 30-60 秒）放到这里。

## 3 种录法，从简到精

### 路径 A：QuickTime + ffmpeg（**最简单，推荐第一次用**）

不用装任何东西。macOS 自带 QuickTime 录屏，本机也已有 ffmpeg。

```bash
# 1. 按 cmd+shift+5 → 选 "录制所选部分" → 框出终端窗口 → 录
#    内容建议：
#      - 拖一份 PDF 进 ~/kb/inbox/（或先准备好 demo PDF）
#      - 打开 Claude Code，说 "ingest 一下"
#      - 演 Claude 报计划 → 你点头 → 它落盘 + commit
#    录 30-60 秒就够，太长 gif 会上 5MB

# 2. 录完得到 ~/Desktop/录屏-2026-XX-XX.mov

# 3. 转 gif（在本 repo 根目录跑）
ffmpeg -i ~/Desktop/录屏-2026-*.mov \
  -vf "fps=10,scale=900:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 docs/demo/ingest-demo.gif

# 4. 看大小：
ls -lh docs/demo/ingest-demo.gif
# 目标 < 5MB。超了 → 降 fps 到 8 或 scale 到 720
```

```bash
# 5. commit & push
git add docs/demo/ingest-demo.gif
git commit -m "docs: add ingest demo gif"
git push
```

### 路径 B：VHS（**可复刻 / 可改 / 可重录，团队场景最佳**）

[VHS](https://github.com/charmbracelet/vhs) 是 Charm Bracelet 的 CLI，吃一份 `.tape` 脚本输出 gif/mp4/webm。最大好处：**改 README 后可以一行命令重录**，不用再开 QuickTime。

```bash
# 装 VHS（前提：Homebrew 能用 / 或 go install）
brew install vhs              # macOS 推荐
# 或：go install github.com/charmbracelet/vhs@latest

# repo 里已经准备好的 tape 文件：
cat docs/demo/init-demo.tape  # 演 init.sh 的部分（init 流程是确定的，可自动化）

# 录：
vhs docs/demo/init-demo.tape
# 输出：docs/demo/init-demo.gif
```

**注意**：VHS 适合录"确定性流程"（init.sh、git 命令、文件操作）。**ingest 流程涉及跟 Claude 真实对话，输出每次不同，VHS 跑不动**。所以：
- `init-demo.tape` → VHS 录（自动化）
- `ingest-demo.gif` → QuickTime 录（真人交互）

也可以两段都放 README，分别讲"装"和"用"。

### 路径 C：asciinema + svg-term（**最专业，矢量清晰**）

```bash
brew install asciinema
npm install -g svg-term-cli

# 录
asciinema rec ingest.cast
# 录完按 ctrl+d 退出

# 转成 svg（无损放大）
svg-term --in ingest.cast --out docs/demo/ingest-demo.svg --window --width 100 --height 30
```

README 里改成 `<img src="docs/demo/ingest-demo.svg">`。优点：清晰、文件小、深色背景；缺点：动画播放控制比 gif 差，部分平台（如旧版微信）不支持。

## 录制脚本（内容建议）

不管用哪种工具，录的内容大致这样讲故事：

```
[场景 1：你扔文件] 5 秒
  $ cp ~/Downloads/some-article.pdf ~/kb/inbox/
  $ ls ~/kb/inbox/
  > some-article.pdf

[场景 2：Claude 处理] 30 秒
  $ claude
  > ingest 一下
  [Claude: 读 SCHEMA + 分页全读 PDF + 报告归档计划]
  > 确认开干
  [Claude: 写 wiki/ + 挪 sources/ + git commit]

[场景 3：成品] 5 秒
  $ ls ~/kb/wiki/
  > some-article.md  ← 新建
  $ cat ~/kb/wiki/some-article.md | head -20
  [展示 wiki 的 frontmatter + 第一节]
  $ cd ~/kb && git log --oneline -1
  > ingest: some-article → wiki/some-article.md
```

整体 30-60 秒。**重点是给陌生人看：拖文件 → 等一会 → 出结构化 wiki**。

## gif 大小控制

GitHub README 里的 gif 建议 **< 5MB**，否则首屏加载慢。如果你录长了：

```bash
# 1. 降分辨率到 720
ffmpeg -i input.mov -vf "fps=10,scale=720:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 output.gif

# 2. 降帧率到 8
ffmpeg -i input.mov -vf "fps=8,scale=900:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 output.gif

# 3. 用 gifsicle 二次压
brew install gifsicle
gifsicle -O3 --lossy=80 output.gif -o output-small.gif

# 4. 还是大？换 webp（GitHub 支持，体积比 gif 小 50%+）
ffmpeg -i input.mov -vcodec libwebp -filter:v fps=10 -lossless 0 -loop 0 -preset default -an -vsync 0 output.webp
# README 里：<img src="docs/demo/ingest-demo.webp">
```

## 替换 README 占位符

录好放进 `docs/demo/ingest-demo.gif` 之后，README 顶部的 `<img>` 标签会自动显示，不用改 markdown。

如果你想换名字 / 用不同格式，编辑 README.md 第 3 行的 `<img src="...">`。
