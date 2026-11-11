function gptex
    set gnuplot_script $argv[1]
    set gnuplot_script_base (basename $gnuplot_script (path extension $gnuplot_script))
    set tikz_file "__gen_tikz.tex"
    set tikz_base __gen_tikz
    set temp_dir (mktemp -d -t gnuplot_tikz_compile_XXXXXXX)
    set a_file $temp_dir/a.tex

    gnuplot $gnuplot_script >$tikz_file

    echo "generated tikz file"

    mv $tikz_file $temp_dir/
    begin
        echo '\documentclass[tikz,convert={density=300, outext=.png}]{standalone}'
        echo '\usepackage{gnuplot-lua-tikz}'
        echo '\usepackage{amsmath}'
        echo '\begin{document}'
        echo "\input{$tikz_base}"
        echo '\end{document}'
    end >$a_file

    cd $temp_dir
    lualatex -shell-escape -interaction=batchmode -jobname=a a.tex
    cd -
    mv $temp_dir/a-1.png ./$gnuplot_script_base.png

    rm -rf $temp_dir
end
