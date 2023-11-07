export XDG_CONFIG_HOME=~/.config
export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"


if [[ $(command -v exa) ]]; then
  alias e='exa --icons --git'
  alias l=e
  alias ls=e
  alias ea='exa -a --icons --git'
  alias la=ea
  alias ee='exa -aahl --icons --git'
  alias ll=ee
  alias et='exa -T -L 3 -a -I "node_modules|.git|.cache" --icons'
  alias lt=et
  alias eta='exa -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
  alias lta=eta
  alias l='clear && ls'
fi
alias :q=exit

# opam configuration
[[ ! -r /home/itt/.opam/opam-init/init.zsh ]] || source /home/itt/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null


. $HOME/.asdf/asdf.sh
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

alias vim=nvim

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export GPG_TTY=$TTY
export XDG_CACHE_HOME=/home/itt/.cache

export DENO_INSTALL="/home/itt/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$HOME/bin:$PATH"

eval $(ssh-agent) > /dev/null 2>&1
ssh-add  ~/.ssh/signing_key > /dev/null 2>&1


export PATH=$HOME/.progate/bin:$PATH
