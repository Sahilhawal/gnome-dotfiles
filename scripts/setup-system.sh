
# ~/dotfiles/scripts/setup-system.sh

# Disable GNOME animations
gsettings set org.gnome.desktop.interface enable-animations false

# Ghostty transparency
echo "background-opacity = 0.8" >> ~/.config/ghostty/config

# Load gnome-settings
dconf load / < ~/dotfiles/gnome-settings-backup.txt
