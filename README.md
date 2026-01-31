# worktree-switch

A zsh function to interactively select and switch between Git worktrees using fzf.

## Features

- Interactive worktree selection with fzf
- Preview panel showing:
  - Worktree path
  - Branch name
  - Recent commits
- Skips selection if only one worktree exists
- Configurable via environment variables

## Requirements

- zsh
- [fzf](https://github.com/junegunn/fzf)
- git

## Installation

### Manual

```bash
# Clone the repository
git clone https://github.com/yourusername/worktree-switch.git

# Add to your .zshrc
source /path/to/worktree-switch/wt.zsh
```

### zinit

```bash
zinit light yourusername/worktree-switch
```

### zplug

```bash
zplug "yourusername/worktree-switch"
```

### oh-my-zsh

```bash
# Clone to oh-my-zsh custom plugins directory
git clone https://github.com/yourusername/worktree-switch.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/worktree-switch

# Add to plugins in .zshrc
plugins=(... worktree-switch)
```

## Usage

```bash
# Navigate to any git repository
cd /path/to/your/repo

# Run the command
wt
```

Use arrow keys to navigate, Enter to select, ESC to cancel.

## Configuration

Add these to your `.zshrc` **before** sourcing the plugin:

```bash
# fzf window height (default: 40%)
export WT_FZF_HEIGHT="50%"

# Preview window position (default: right:50%:wrap)
export WT_FZF_PREVIEW_POSITION="bottom:40%:wrap"

# Number of recent commits to show in preview (default: 5)
export WT_LOG_COUNT=10
```

| Variable | Default | Description |
|----------|---------|-------------|
| `WT_FZF_HEIGHT` | `40%` | Height of the fzf selection window |
| `WT_FZF_PREVIEW_POSITION` | `right:50%:wrap` | Position and size of preview pane |
| `WT_LOG_COUNT` | `5` | Number of recent commits shown in preview |

## License

MIT
