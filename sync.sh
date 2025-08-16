
#!/bin/bash
# sync.sh - Run backup.sh and push changes if any

set -e

DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR" || { echo "Dotfiles directory not found!"; exit 1; }

# Run your backup script
"$DOTFILES_DIR/backup.sh"

if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "Auto backup on $(date '+%Y-%m-%d %H:%M:%S')"
  git push origin main
  echo "✅ Backup committed and pushed."
else
  echo "ℹ️ No changes to commit."
fi
