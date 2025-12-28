if status is-interactive
end

# opam configuration
source /home/itt/.opam/opam-init/init.fish >/dev/null 2>/dev/null; or true

abbr -a -- l eza --color=always --icons=always
abbr -a -- ls eza --color=always --icons=always -a
abbr -a -- ll eza --color=always --icons=always -al
abbr -a -- lt eza --color=always --icons=always -T --git-ignore
abbr -a -- zj zellij

set -x EDITOR hx
set -x PNPM_HOME $HOME/.local/share/pnpm
set -x STEEL_LSP_HOME $HOME/.config/steel-lsp

fish_add_path $HOME/.dotnet/tools
fish_add_path $HOME/.moon/bin
fish_add_path $HOME/.bun/bin
fish_add_path $HOME/go/bin
fish_add_path $PNPM_HOME
fish_add_path $HOME/.npm-global/bin

starship init fish | source
mise activate fish | source
