# VHS Demo for worktree-switch
# Run: vhs demo.tape

# Configuration
Output demo.gif
Set FontSize 16
Set Width 1000
Set Height 600
Set Theme "Catppuccin Mocha"
Set Padding 20
Set Shell "zsh"

# Setup - source zshrc and the plugin
Hide
Type "source ~/.zshrc"
Enter
Sleep 1s
Type "source wt.zsh"
Enter
Sleep 500ms
Show

# Title
Type "# wt - Interactive Git Worktree Manager"
Sleep 1s
Enter
Sleep 500ms

# Show worktree list
Type "git worktree list"
Sleep 500ms
Enter
Sleep 2s

# Run wt command for interactive selection
Type "wt"
Sleep 500ms
Enter
Sleep 2s

# Navigate with arrow keys in fzf to show different previews
Down
Sleep 1.5s
Down
Sleep 1.5s
Up
Sleep 1.5s

# Select with Enter
Enter
Sleep 1s

# Show current directory
Type "pwd"
Enter
Sleep 1.5s

# End
Sleep 1s
