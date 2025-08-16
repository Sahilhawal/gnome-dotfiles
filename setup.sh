#!/bin/bash
set -e

echo "🚀 Setting up your environment..."

DOTFILES_DIR="$HOME/dotfiles"

# 1. Symlink dotfiles
declare -A FILES_TO_SYMLINK=(
    [".bashrc"]="$HOME/.bashrc"
    [".gitconfig"]="$HOME/.gitconfig"
    [".p10k.zsh"]="$HOME/.p10k.zsh"
    [".profile"]="$HOME/.profile"
    [".tmux.conf"]="$HOME/.tmux.conf"
    [".zshrc"]="$HOME/.zshrc"
)

for file in "${!FILES_TO_SYMLINK[@]}"; do
    target=${FILES_TO_SYMLINK[$file]}
    echo "🔗 Linking $file → $target"
    ln -sf "$DOTFILES_DIR/$file" "$target"
done

# Config folder symlinks
mkdir -p ~/.config
for dir in ghostty lazygit nvim; do
    if [ -d "$DOTFILES_DIR/.config/$dir" ]; then
        echo "🔗 Linking $dir config"
        ln -sf "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
    fi
done

# Scripts symlinks
if [ -d "$DOTFILES_DIR/scripts" ]; then
    for script in "$DOTFILES_DIR/scripts"/*; do
        script_name=$(basename "$script")
        echo "🔗 Linking script: $script_name"
        ln -sf "$script" "$HOME/$script_name"
    done
fi

# 2. Restore GNOME settings & tweaks
if command -v dconf >/dev/null 2>&1 && [ -f "$DOTFILES_DIR/gnome-settings-backup.txt" ]; then
    echo "🖥 Restoring GNOME settings..."
    dconf load / < "$DOTFILES_DIR/gnome-settings-backup.txt"

    echo "✨ Disabling GNOME animations..."
    gsettings set org.gnome.desktop.interface enable-animations false

    echo "🌫 Setting Ghostty transparency..."
    mkdir -p ~/.config/ghostty
    echo "background-opacity = 0.8" >> ~/.config/ghostty/config
else
    echo "⚠️ GNOME settings backup not found or dconf missing."
fi

# 3. Install packages from apt-packages.txt
if [ -f "$DOTFILES_DIR/apt-packages.txt" ]; then
    echo "📦 Installing packages from apt-packages.txt..."
    sudo apt update
    grep -vE 'Listing\.\.\.|^$' "$DOTFILES_DIR/apt-packages.txt" | xargs sudo apt install -y
else
    echo "⚠️ No apt-packages.txt found, installing defaults..."
    sudo apt update
    sudo apt install -y neovim tmux git curl zsh
fi

# 4. Restore oh-my-zsh if present
if [ -d "$DOTFILES_DIR/oh-my-zsh" ]; then
    echo "💡 Restoring oh-my-zsh..."
    rm -rf ~/.oh-my-zsh
    ln -sf "$DOTFILES_DIR/oh-my-zsh" ~/.oh-my-zsh
fi

# 5. Install other package managers' packages if lists exist
[ -f "$DOTFILES_DIR/cargo-packages.txt" ] && \
    echo "📦 Installing Cargo packages..." && \
    xargs cargo install < "$DOTFILES_DIR/cargo-packages.txt"

[ -f "$DOTFILES_DIR/npm-packages.txt" ] && \
    echo "📦 Installing npm packages..." && \
    xargs npm install -g < "$DOTFILES_DIR/npm-packages.txt"

[ -f "$DOTFILES_DIR/pip-packages.txt" ] && \
    echo "📦 Installing pip packages..." && \
    pip install -r "$DOTFILES_DIR/pip-packages.txt"

# 6. GNOME extensions restore
if [ -d "$DOTFILES_DIR/gnome-extensions" ]; then
    echo "🎨 Installing GNOME extensions..."
    mkdir -p ~/.local/share/gnome-shell/extensions
    cp -r "$DOTFILES_DIR/gnome-extensions/"* ~/.local/share/gnome-shell/extensions/
fi

# 7. Set Zsh as default shell
if command -v zsh >/dev/null 2>&1; then
    echo "💻 Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
fi

# Restore keyboard shortcuts
if command -v dconf >/dev/null 2>&1; then
    echo "🎹 Restoring keyboard shortcuts..."
    if [ -f "$HOME/dotfiles/keyboard-shortcuts-backup.txt" ]; then
        dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$HOME/dotfiles/keyboard-shortcuts-backup.txt"
    fi
    if [ -f "$HOME/dotfiles/wm-keybindings-backup.txt" ]; then
        dconf load /org/gnome/desktop/wm/keybindings/ < "$HOME/dotfiles/wm-keybindings-backup.txt"
    fi
else
    echo "⚠️ dconf not installed, skipping keyboard shortcuts restore."
fi
echo "✅ Setup complete! Log out & log back in to apply all changes."
