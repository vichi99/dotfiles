
# Dotfiles

Personal configuration files backup and management for macOS.

## Structure

```
config/     # ~/.config/ directory contents
home/       # ~/ (home directory) dotfiles
```

## Usage

### Backup current configurations

```bash
./backup.sh
```

### Restore configurations

```bash
# Copy config files
cp -r config/* ~/.config/

# Copy home dotfiles
cp home/.* ~/
```

## Dependencies

### SketchyBar setup

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
brew install font-hack-nerd-font
brew install font-sf-pro

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.16/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.20/icon_map_fn.sh -o ~/.config/sketchybar/plugins/icon_map_fn.sh

defaults write com.knollsoft.Rectangle screenEdgeGapTop -int 4
```

Reference: <https://www.josean.com/posts/sketchybar-setup>

### Neovim dependencies

```bash
brew install ripgrep
brew install node
```
