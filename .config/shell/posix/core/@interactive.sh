#
# Core configuration module
#

# Options
# =======

# Fetch the current TTY.
[ ! "$TTY" ] && TTY="$(tty)"

# Disable control flow (^S/^Q).
[ -r "${TTY:-}" ] && [ -w "${TTY:-}" ] && command -v stty >/dev/null \
    && stty -ixon <"$TTY" >"$TTY" || true

# General parameters and options.
HISTFILE=        # in-memory history only
set -o noclobber # do not allow '>' to truncate existing files, use '>|'
set -o notify    # report the status of background jobs immediately

# Aliases
# =======

# Elementary.
alias reload='exec "$SHELL"' # reload the current shell configuration
alias sudo='sudo '            # preserve aliases when running sudo
alias su='su -l'              # safer, simulate a real login
alias c='clear'

# Human readable output.
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h' du='du -h'

# Verbose and safe file operations.
alias cp='cp -vi' mv='mv -vi' ln='ln -vi' rm='rm -vI'

# Directory listing.
alias dud='du -d1' # show total disk usage for direct subdirectories only
alias ls='ls --color=auto --group-directories-first' # list directories first
alias ll='ls -lh' # list human readable sizes
alias l='ll -A' # list human readable sizes, all files
alias lr='ll -R' # list human readable sizes, recursively
alias lx='ll -XB' # list sorted by extension (GNU only)
alias lk='ll -Sr' # list sorted by size, largest last
alias lt='ll -tr' # list sorted by modification time, most recent last

# Making/Changing directories.
alias mkdir='mkdir -pv'
alias mkd='mkdir'
alias rmd='rmdir'
take() { [[ -n ${1} ]] && mkdir -p ${1} && builtin cd ${1}; }

# Systemd convenience.
alias sc='systemctl'
alias scu='sc --user'
alias jc='journalctl --catalog'
alias jcb='jc --boot=0'
alias jcf='jc --follow'
alias jce='jc -b0 -p err..alert'

# Simple progress bar output for downloaders by default.
alias curl='curl --progress-bar'
alias wget='wget -q --no-hsts --show-progress'

# Simple and silent desktop opener.
alias open='nohup xdg-open </dev/null >|$(mktemp --tmpdir nohup.XXXX) 2>&1'
alias o='open'

# Preferred apps
alias browse='${BROWSER}'
alias edit='${VISUAL:-$EDITOR}'
alias b='browse'
alias e='edit'
alias p='${PAGER}'

# Git/yadm
alias g='git'
alias y='yadm'

# Cht.sh
alias ch='cht.sh'

# Command: Back up a file. Usage "backupthis <filename/directory>"
backupthis() { cp -riv $1 ${1}-$(date +%Y%m%d%H%M).backup; }

# Pager
# =====

# Return if requirements are not met
if [ "$TERM" != "dumb" ]; then
    # Set default less options.
    mkdir -p ${XDG_STATE_HOME}/less
    export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
    export LESSKEY="${XDG_STATE_HOME}/less/key"
    export LESSHISTSIZE=50
    export LESS='-QRSMi -#.25 --no-histdups'
    export SYSTEMD_LESS="${LESS}"
    # Set default colors for less.
    export LESS_TERMCAP_mb=$'\E[01;31m'    # begins blinking
    export LESS_TERMCAP_md=$'\E[01;34m'    # begins bold
    export LESS_TERMCAP_me=$'\E[0m'        # ends mode
    export LESS_TERMCAP_so=$'\E[00;47;30m' # begins standout-mode
    export LESS_TERMCAP_se=$'\E[0m'        # ends standout-mode
    export LESS_TERMCAP_us=$'\E[01;33m'    # begins underline
    export LESS_TERMCAP_ue=$'\E[0m'        # ends underline
fi

# Local config
# ============
# IMPORTANT: MUST BE AT THE END TO OVERRIDE

if test -f "${HOME}/.shellconf.local"; then
    source "${HOME}/.shellconf.local"
fi
