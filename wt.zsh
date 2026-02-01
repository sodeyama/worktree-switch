# worktree-switch - Interactive Git worktree selector
# https://github.com/yourusername/worktree-switch
#
# Usage: source /path/to/wt.zsh
# Run:   wt [command] [options]

# Configuration (can be overridden in .zshrc before sourcing)
: ${WT_FZF_HEIGHT:=40%}
: ${WT_FZF_PREVIEW_POSITION:=right:50%:wrap}
: ${WT_LOG_COUNT:=5}
: ${WT_BASE_DIR:=..}

# Store script path for fzf preview
WT_SCRIPT_PATH="${0:A}"

# Helper: Check if inside a Git repository
_wt_check_git() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: Not inside a Git repository" >&2
    return 1
  fi
}

# Helper: Check if fzf is installed
_wt_check_fzf() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf is not installed. Please install it first." >&2
    echo "  brew install fzf  # macOS" >&2
    echo "  apt install fzf   # Ubuntu/Debian" >&2
    return 1
  fi
}

# Helper: Get worktree list
_wt_get_worktrees() {
  git worktree list
}

# Helper: Generate preview for a worktree line
_wt_preview() {
  local line="$1"
  local log_count="$2"
  local path="${line%% *}"
  local branch="${line##*\[}"
  branch="${branch%\]}"

  # Find git command
  local git_cmd
  git_cmd=$(command -v git 2>/dev/null || echo "/usr/bin/git")

  echo "Path: $path"
  echo "Branch: $branch"
  echo ""
  echo "--- Recent Commits ---"
  "$git_cmd" -C "$path" log --oneline -"$log_count" 2>/dev/null
  echo ""
  echo "--- Last Commit ---"
  "$git_cmd" -C "$path" log -1 --format="Author: %an <%ae>%nDate:   %ad%n%n%s%n%n%b" --date=short 2>/dev/null
}

# Helper: Select worktree with fzf
_wt_select_worktree() {
  local header="${1:-Select a worktree (ESC to cancel)}"
  local worktrees
  worktrees=$(_wt_get_worktrees)

  if [[ -z "$worktrees" ]]; then
    echo "Error: No worktrees found" >&2
    return 1
  fi

  # Export variables for fzf preview subprocess
  export WT_LOG_COUNT
  export WT_SCRIPT_PATH

  echo "$worktrees" | fzf \
    --height="${WT_FZF_HEIGHT}" \
    --reverse \
    --header="$header" \
    --preview="PATH=\"$PATH\" zsh -c 'source \"$WT_SCRIPT_PATH\"; _wt_preview \"\$1\" $WT_LOG_COUNT' -- {}" \
    --preview-window="${WT_FZF_PREVIEW_POSITION}"
}

# Command: help
_wt_help() {
  cat <<'EOF'
wt - Interactive Git worktree manager

Usage:
  wt              Interactive worktree selection and switch
  wt new <branch> Create a new worktree for the specified branch
  wt rm [options] Remove a worktree (interactive selection)
  wt help         Show this help message

Options for 'rm':
  -f, --force     Force remove even with uncommitted changes

Configuration (environment variables):
  WT_FZF_HEIGHT           fzf window height (default: 40%)
  WT_FZF_PREVIEW_POSITION Preview pane position (default: right:50%:wrap)
  WT_LOG_COUNT            Number of commits in preview (default: 5)
  WT_BASE_DIR             Base directory for new worktrees (default: ..)

Examples:
  wt                      # Select and switch to a worktree
  wt new feature/login    # Create worktree for feature/login branch
  wt rm                   # Select and remove a worktree
  wt rm -f                # Force remove a worktree
EOF
}

# Command: new - Create a new worktree
_wt_new() {
  local branch="$1"

  if [[ -z "$branch" ]]; then
    echo "Error: Branch name is required" >&2
    echo "Usage: wt new <branch>" >&2
    return 1
  fi

  _wt_check_git || return 1

  # Determine worktree path
  local repo_root
  repo_root=$(git rev-parse --show-toplevel)
  local repo_name
  repo_name=$(basename "$repo_root")
  local worktree_dir
  # Sanitize branch name for directory (replace / with -)
  local dir_name="${branch//\//-}"
  worktree_dir="${repo_root}/${WT_BASE_DIR}/${repo_name}-${dir_name}"

  # Check if branch exists
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    # Branch exists, checkout existing branch
    echo "Creating worktree for existing branch: $branch"
    git worktree add "$worktree_dir" "$branch"
  else
    # Branch doesn't exist, create new branch
    echo "Creating worktree with new branch: $branch"
    git worktree add -b "$branch" "$worktree_dir"
  fi

  if [[ $? -eq 0 ]]; then
    echo "Created worktree at: $worktree_dir"
    cd "$worktree_dir" || return 1
    echo "Switched to: $worktree_dir"
  else
    echo "Error: Failed to create worktree" >&2
    return 1
  fi
}

# Command: rm - Remove a worktree
_wt_rm() {
  local force=""

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force)
        force="--force"
        shift
        ;;
      *)
        echo "Error: Unknown option: $1" >&2
        echo "Usage: wt rm [-f|--force]" >&2
        return 1
        ;;
    esac
  done

  _wt_check_git || return 1
  _wt_check_fzf || return 1

  # Get current worktree path
  local current_dir
  current_dir=$(pwd)

  # Select worktree to remove
  local selected
  selected=$(_wt_select_worktree "Select a worktree to REMOVE (ESC to cancel)")

  if [[ -z "$selected" ]]; then
    echo "Cancelled"
    return 0
  fi

  local target_dir
  target_dir=$(echo "$selected" | awk '{print $1}')

  # Prevent removing the main worktree (bare check)
  local main_worktree
  main_worktree=$(git worktree list | head -1 | awk '{print $1}')

  if [[ "$target_dir" == "$main_worktree" ]]; then
    echo "Error: Cannot remove the main worktree" >&2
    return 1
  fi

  # Confirm removal
  echo "Removing worktree: $target_dir"

  # If we're in the worktree being removed, move to main worktree first
  if [[ "$current_dir" == "$target_dir"* ]]; then
    echo "Moving to main worktree before removal..."
    cd "$main_worktree" || return 1
  fi

  # Remove worktree
  if git worktree remove $force "$target_dir"; then
    echo "Worktree removed successfully"
    if [[ "$current_dir" == "$target_dir"* ]]; then
      echo "Switched to: $main_worktree"
    fi
  else
    echo "Error: Failed to remove worktree" >&2
    echo "Hint: Use 'wt rm -f' to force remove" >&2
    return 1
  fi
}

# Command: (default) - Interactive switch
_wt_switch() {
  _wt_check_git || return 1
  _wt_check_fzf || return 1

  local worktrees
  worktrees=$(_wt_get_worktrees)

  if [[ -z "$worktrees" ]]; then
    echo "Error: No worktrees found" >&2
    return 1
  fi

  # Count worktrees - if only one, skip selection
  local worktree_count
  worktree_count=$(echo "$worktrees" | wc -l | tr -d ' ')

  if [[ "$worktree_count" -eq 1 ]]; then
    echo "Only one worktree exists. Nothing to switch."
    return 0
  fi

  # Interactive selection with fzf
  local selected
  selected=$(_wt_select_worktree)

  if [[ -z "$selected" ]]; then
    echo "Cancelled"
    return 0
  fi

  local target_dir
  target_dir=$(echo "$selected" | awk '{print $1}')

  if [[ -d "$target_dir" ]]; then
    cd "$target_dir" || return 1
    echo "Switched to: $target_dir"
  else
    echo "Error: Directory does not exist: $target_dir" >&2
    return 1
  fi
}

# Main function
wt() {
  local cmd="${1:-}"

  case "$cmd" in
    help|--help|-h)
      _wt_help
      ;;
    new|add)
      shift
      _wt_new "$@"
      ;;
    rm|remove)
      shift
      _wt_rm "$@"
      ;;
    "")
      _wt_switch
      ;;
    *)
      echo "Error: Unknown command: $cmd" >&2
      echo "Run 'wt help' for usage information" >&2
      return 1
      ;;
  esac
}
