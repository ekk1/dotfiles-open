alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lal='ls -al'
alias t='tmux'
alias ta='tmux a'
alias td='tmux deta'
alias pa='ps aux'
alias pf='ps axjfe'
alias g='grep'
alias gv='grep -v'
alias gi='grep -i'
alias gvi='grep -vi'
alias giv='grep -iv'
alias g-='egrep -v "(^$|^#)"'
alias s='ssh'
alias py='python3'
alias gg='git grep'
alias q='git status'
alias gc='git commit'
alias v='vim'
alias vv='vim ~/.vimrc'
alias p='generate password'
alias o='get password'
alias ww='wget --limit-rate=3000k'
alias jq='python3 /path/to/jq.py'
alias rr='ranger'

# PROXY
function terminalProxyStart() {
    export http_proxy=http://127.0.0.1:8118
    export https_proxy=http://127.0.0.1:8118
}                                                                                                                                                                                                        
function noterminalProxy() {
    export http_proxy=
    export https_proxy=
}

# ANSIBLE_RELATED
alias ae='ansible-vault encrypt_string'

# EXPORTS
export PATH=$PATH
export EDITOR=vim
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

alias ch='chromium --proxy-server=socks5://192.168.xxxx:xxxxx --proxy-bypass-list=192.168.* --ozone-platform-hint=auto'
# MOZ_ENABLE_WAYLAND=1
