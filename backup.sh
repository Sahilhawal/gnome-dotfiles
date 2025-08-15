
#!/bin/bash
set -e

echo "💾 Backing up system configuration to dotfiles..."

DOTFILES_DIR="$HOME/dotfiles"

# Backup apt packages
echo "📦 Saving apt packages..."
dpkg --get-selections | awk '{print $1}' > "$DOTFILES_DIR/apt-packages.txt"

# Backup cargo packages
if command -v cargo >/dev/null 2>&1; then
    echo "📦 Saving cargo packages..."
    cargo install --list | awk 'NR>1 {print $1}' > "$DOTFILES_DIR/cargo-packages.txt"
fi

# Backup npm packages
if command -v npm >/dev/null 2>&1; then
    echo "📦 Saving npm packages..."
    npm list -g --depth=0 | awk -F ' ' '/──/ {print $2}' | cut -d@ -f1 > "$DOTFILES_DIR/npm-packages.txt"
fi

# Backup pip packages
if command -v pip >/dev/null 2>&1; then
    echo "📦 Saving pip packages..."
    pip freeze > "$DOTFILES_DIR/pip-packages.txt"
fi

# Backup oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "💡 Backing up oh-my-zsh..."
    rsync -a --delete "$HOME/.oh-my-zsh/" "$DOTFILES_DIR/oh-my-zsh/"
fi

# Backup GNOME settings
if command -v dconf >/dev/null 2>&1; then
    echo "🖥 Backing up GNOME settings..."
    dconf dump / > "$DOTFILES_DIR/gnome-settings-backup.txt"
fi

echo "✅ Backup complete!"
