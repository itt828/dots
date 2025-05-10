function gf
    # set -l repodir (ghq list | fzf --preview='eza -Ta --git-ignore $(ghq root)/{}') && cd (ghq root)/$repodir
    set -l repodir (ghq list | tv --preview 'eza -Ta --git-ignore $(ghq root)/{}') && cd (ghq root)/$repodir
end
