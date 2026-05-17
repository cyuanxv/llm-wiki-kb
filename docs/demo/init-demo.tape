# VHS tape — 演 init.sh 流程
# 跑法：vhs docs/demo/init-demo.tape
# 输出：docs/demo/init-demo.gif

Output docs/demo/init-demo.gif

Set FontSize 14
Set Width 900
Set Height 540
Set Theme "Catppuccin Mocha"
Set TypingSpeed 50ms

# 准备 sandbox（避免污染真实 ~/kb）
Hide
Type "export SANDBOX=$(mktemp -d) && export HOME=$SANDBOX && cd /tmp/kb-starter-demo && rm -rf /tmp/kb-starter-demo && git clone https://github.com/cyuanxv/llm-wiki-kb.git /tmp/kb-starter-demo && cd /tmp/kb-starter-demo"
Enter
Sleep 2s
Show

Type "# 1 行 clone 这个 starter kit"
Sleep 800ms
Enter
Type "git clone https://github.com/cyuanxv/llm-wiki-kb.git && cd llm-wiki-kb"
Sleep 1s
Enter
Sleep 2s

Type "# 跑 init 脚本"
Sleep 600ms
Enter
Type "./init.sh"
Enter
Sleep 1500ms

# 回答 4 个问题
Type "$SANDBOX/kb"
Enter
Sleep 1s
Type "y"
Enter
Sleep 1s
Type "n"
Enter
Sleep 800ms
Type "n"
Enter
Sleep 3s

Type "# 完成。看产物："
Sleep 600ms
Enter
Type "ls $SANDBOX/kb/"
Enter
Sleep 2s

Type "# 跟 Claude 说 'ingest 一下' 就可以开始用了 🎉"
Sleep 1200ms
Enter
Sleep 3s

# 清理 sandbox
Hide
Type "rm -rf $SANDBOX /tmp/kb-starter-demo"
Enter
Show
