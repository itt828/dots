if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    # ~/.local/bin/mise activate fish | source
    fish_add_path $HOME/.dotnet/tools
    #    abbr -a -- hx helix
    abbr -a -- ls eza --color=always --icons=always -a
    abbr -a -- ll eza --color=always --icons=always -al
    abbr -a -- lt eza --color=always --icons=always -T
    abbr -a -- zj zellij
    set -x KUBECONFIG '/home/itt/.kube/config'
    set -x EDITOR hx
    set -x MEMO_DIR /home/itt/memo/oxide-memos
    set -x MEMO_DAILY_DIR $MEMO_DIR/daily
end

# opam configuration
source /home/itt/.opam/opam-init/init.fish >/dev/null 2>/dev/null; or true
mise activate fish | source
