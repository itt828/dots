function uve
    echo $argv[1]
    uv sync --script $argv[1]
    set VENV_PATH (dirname (uv python find --script $argv[1]))"/activate.fish"
    fish -c "source $VENV_PATH && $EDITOR $argv[1]"
end
