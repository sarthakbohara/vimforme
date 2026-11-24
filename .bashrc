# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

cd

crun() {
    case "$1" in
        -h|--help)
            cat <<EOF
Usage: crun <gcc-args> -- <program-args>

Compile with gcc, run the program, then remove the executable.

Examples:
  crun main.c
  crun main.c util.c -lm
  crun main.c -lm -- hello world
EOF
            return

            ;;
    esac

    local gcc_args=()
    local run_args=()
    local after_sep=false

    for arg; do
        if $after_sep; then
            run_args+=("$arg")
        elif [[ $arg == -- ]]; then
            after_sep=true
        else
            gcc_args+=("$arg")
        fi
    done

    gcc "${gcc_args[@]}" &&
        ./a.out "${run_args[@]}" &&
        rm -f a.out
}



wcrun() {
    case "$1" in
        -h|--help)
            cat <<EOF
Usage: wcrun <gcc-args> -- <program-args>

Same as crun, but compiles with -w (suppresses warnings).

Examples:
  wcrun main.c
  wcrun main.c util.c -lm
  wcrun main.c -lm -- hello world
EOF
            return
            ;;
    esac

    local gcc_args=(-w)
    local run_args=()
    local after_sep=false

    for arg; do
        if $after_sep; then
            run_args+=("$arg")
        elif [[ $arg == -- ]]; then
            after_sep=true
        else
            gcc_args+=("$arg")
        fi
    done

    gcc "${gcc_args[@]}" -o wa &&
        ./wa "${run_args[@]}" &&
        rm -f wa
}

dcrun() {
    case "$1" in
        -h|--help)
            cat <<EOF
Usage: dcrun <gcc-args> -- <program-args>

Same as crun, but compiles with -g (debugger flags).

Examples:
  dcrun main.c
  dcrun main.c util.c -lm
  dcrun main.c -lm -- hello world
EOF
            return
            ;;
    esac


    if [[ ${1-} == -h || ${1-} == --help ]]; then
        printf 'Usage: dcrun [gcc-args...] [-- program-args...]\n'
        return 0
    fi

    local gcc_args=(-w -g)
    local run_args=()
    local after_sep=false
    local arg status

    for arg in "$@"; do
        if [[ $after_sep == true ]]; then
            run_args+=("$arg")
        elif [[ $arg == -- ]]; then
            after_sep=true
        else
            gcc_args+=("$arg")
        fi
    done

    gcc "${gcc_args[@]}" -o da || return
    gdb --args ./da "${run_args[@]}"
    status=$?
    rm -f da
}


cpp() {
    local compile_args=()
    local run_args=()

    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "--" ]]; then
            shift
            run_args=("$@")
            break
        fi
        compile_args+=("$1")
        shift
    done

    g++ -std=c++20 "${compile_args[@]}" -o cpp.out || return
    ./cpp.out "${run_args[@]}"
    local status=$?
    rm -f cpp.out
    return $status
}

PS1=$'\uFFE5 '

export PATH="$HOME/.local/bin:$PATH"

val(){
gcc "$1" -o val.out && valgrind ./val.out
}

lsa(){
git status
}

py() {
python3 "$@"
}

export EDITOR=vim
export VISUAL=vim
