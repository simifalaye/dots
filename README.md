<h1 align="center">Dotfiles</h1>
<p align="center">My dotfiles for linux, macos & windows, managed by Chezmoi</p>
<p align="center">
  <img src="https://img.shields.io/badge/OS-ubuntu_22.04-orange.svg" />
  <img src="https://img.shields.io/badge/Editor-vim-brightgreen.svg" />
  <img src="https://img.shields.io/badge/Shell-zsh-yellow.svg" />
  <br><br>
  <img src="https://i.imgur.com/pVGr7tX.png">
</p>

# Pre-Install Requirements

## Windows

- Allow script execution: `Set-ExecutionPolicy Unrestricted`

# Install

## Linux/MacOS

**curl**:

```sh
export PATH="$HOME/.local/bin:$PATH"; sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b $HOME/.local/bin init --apply https://github.com/simifalaye/dotfiles.git
```

**wget** (if curl isn't installed by default):

```sh
export PATH="$HOME/.local/bin:$PATH"; sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b $HOME/.local/bin init --apply https://github.com/simifalaye/dotfiles.git
```

## Windows

```powershell
$env:Path = "$HOME\.local\bin;$env:Path"; iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b '~/.local/bin' -- init --apply https://github.com/simifalaye/dotfiles.git"
```
