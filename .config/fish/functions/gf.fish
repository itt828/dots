function gf
    set -l repodir (ghq list | fzf) && cd (ghq root)/$repodir
end
