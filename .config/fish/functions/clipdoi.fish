function clipdoi
    set doi $argv[1]
    if not string match -q "https://doi.org/*" $doi
        set doi https://doi.org/$doi
    end
    curl -sLH "Accept: text/bibliography; style=bibtex" $doi | wl-copy
end
