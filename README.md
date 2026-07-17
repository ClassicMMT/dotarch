# Install

```bash
sudo pacman -S stow
git clone <repo> ~/.dotfiles
cd ~/.dotfiles && stow -t ~ .
```

# Manual configuration required

- keyd — key remapping, lives in `/etc`. see [etc/keyd/README.rst](etc/keyd/README.rst)
- fonts — install SF Pro, or fontconfig falls back
