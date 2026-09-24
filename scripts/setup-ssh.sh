#!/bin/sh
# vim: ft=sh

gh_path="$HOME/.local/bin/gh"

dotfiles_dir="${1}"
ssh_email="${2}"
ssh_key_path="${3}"
if [ -z "${dotfiles_dir}" ] || [ -z "${ssh_email}" ] || [ -z "${ssh_key_path}" ]; then
    echo "Error: Must provide all args: ssh_email, ssh_key_path and dotfiles_dir!" >&2
    exit 1
fi

printf '\033[36mChecking SSH key setup...\033[0m\n'

# Generate SSH key if missing.
if [ ! -f "$ssh_key_path" ]; then
    printf '\033[33mNo SSH key found. Generating ed25519 key...\033[0m\n'

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    ssh-keygen \
        -t ed25519 \
        -C "$ssh_email" \
        -f "$ssh_key_path" \
        -N ""
fi

# Use the chezmoi-managed GitHub CLI if it exists.
if [ -x "$gh_path" ]; then
    gh="$gh_path"
elif command -v gh >/dev/null 2>&1; then
    gh="$(command -v gh)"
else
    gh=""
fi

# Check if GitHub CLI is installed and authenticated.
if [ -n "$gh" ]; then
    if ! "$gh" auth status >/dev/null 2>&1; then
        printf '\033[33mAuthenticating with GitHub CLI to register SSH key...\033[0m\n'

        "$gh" auth login \
            --web \
            -h github.com \
            -p ssh \
            -w

        "$gh" ssh-key add \
            "${ssh_key_path}.pub" \
            --title "$(uname -s)-$(hostname)"
    fi
fi

# Swap chezmoi source repository origin from HTTPS to SSH.
if [ -d "$dotfiles_dir/.git" ]; then
    current_remote="$(git -C "$dotfiles_dir" remote get-url origin 2>/dev/null || true)"
    case "$current_remote" in
        https://github.com/*)
            ssh_remote="git@github.com:${current_remote#https://github.com/}"
            printf '\033[32mConverting chezmoi Git origin to SSH: %s\033[0m\n' "$ssh_remote"
            git -C "$dotfiles_dir" remote set-url origin "$ssh_remote"
            ;;
    esac
fi
