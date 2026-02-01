# VHS Demo for worktree-switch
# Run: vhs demo.tape

# Configuration
Output demo.gif
Set FontSize 16
Set Width 900
Set Height 550
Set Theme "Catppuccin Mocha"
Set Padding 20

# Setup - source the plugin
Hide
Type "source wt.zsh"
Enter
Sleep 500ms
Show

# Title
Type "# wt - Interactive Git Worktree Manager"
Sleep 1s
Enter
Sleep 500ms

# Create new worktrees using wt new
Type "wt new feature/awesome"
Sleep 500ms
Enter
Sleep 2s

Type "wt new bugfix/hotfix"
Sleep 500ms
Enter
Sleep 2s

# Show worktree list
Type "git worktree list"
Sleep 500ms
Enter
Sleep 2s

# Run wt command for interactive selection
Type "wt"
Sleep 500ms
Enter
Sleep 1.5s

# Navigate with arrow keys in fzf
Down
Sleep 600ms
Up
Sleep 600ms
Up
Sleep 600ms

# Select with Enter
Enter
Sleep 1s

# Show current directory
Type "pwd"
Enter
Sleep 1.5s

# End
Sleep 1s
