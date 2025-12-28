function clipdoi
    set doi $argv[1]
    if string match -qr '10\.48550/arXiv\.(.+)' $doi
        # arXiv IDを抽出
        set arxiv_id (string replace -r '10\.48550/arXiv\.' '' $doi)
        set bibtex_url "https://arxiv.org/bibtex/$arxiv_id"

        # bibtex を取得
        set bibtex (curl -s $bibtex_url | string match -r '@.*')

        if test -z "$bibtex"
            echo "Failed to get BibTeX from arXiv"
            return 1
        end
    else
        if not string match -q "https://doi.org/*" $doi
            set doi https://doi.org/$doi
        end
    end
    set bib (curl -sLH "Accept: text/bibliography; style=bibtex" $doi)
    echo $bib
    echo $bib | wl-copy
end
