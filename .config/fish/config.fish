if status is-interactive
    starship init fish | source
    fish_add_path $HOME/.dotnet/tools
    abbr -a -- ls eza --color=always --icons=always -a
    abbr -a -- ll eza --color=always --icons=always -al
    abbr -a -- lt eza --color=always --icons=always -T
    abbr -a -- zj zellij
    set -x EDITOR hx
end

# opam configuration
source /home/itt/.opam/opam-init/init.fish >/dev/null 2>/dev/null; or true
mise activate fish | source
