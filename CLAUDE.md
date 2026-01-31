# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**worktree-switch** is a zsh plugin that provides an interactive interface (`wt` command) for selecting and navigating between Git worktrees using fzf.

## File Structure

- `wt.zsh` - Main shell function
- `worktree-switch.plugin.zsh` - Entry point for oh-my-zsh and plugin managers

## Core Functionality

The `wt` function:
1. Verifies execution within a Git repository
2. Checks for fzf availability (with install hints)
3. Lists all Git worktrees via `git worktree list`
4. Skips selection if only one worktree exists
5. Presents an fzf selector with preview showing path, branch, and recent commits
6. Changes directory to the selected worktree

## Dependencies

- **zsh**: Shell environment
- **fzf**: Fuzzy finder for interactive selection
- **git**: For worktree operations

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WT_FZF_HEIGHT` | `40%` | fzf window height |
| `WT_FZF_PREVIEW_POSITION` | `right:50%:wrap` | Preview pane position |
| `WT_LOG_COUNT` | `5` | Number of commits in preview |

## Testing

```bash
source wt.zsh
cd /path/to/repo/with/multiple/worktrees
wt
```
