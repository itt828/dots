status is-interactive; or return

# Also restore after Ctrl+C, which can interrupt the sudo function itself.
function __fcitx_sudo_restore --on-event fish_prompt
    if set -q __fcitx_sudo_was_active
        set -e __fcitx_sudo_was_active
        command fcitx5-remote -o >/dev/null 2>&1
    end
end

# Ghostty installs its sudo wrapper at the first prompt. Wrap it afterwards
# so its TERMINFO handling (and any other existing sudo wrapper) is preserved.
function __fcitx_sudo_setup --on-event fish_preexec
    functions -e __fcitx_sudo_setup

    if functions -q sudo
        functions -c sudo __fcitx_sudo_command
    else
        function __fcitx_sudo_command
            command sudo $argv
        end
    end

    function sudo --wraps sudo --description 'Run sudo with the input method inactive'
        if command -q fcitx5-remote
            set -l im_state (command fcitx5-remote 2>/dev/null)
            if test "$im_state" = 2
                set -g __fcitx_sudo_was_active 1
                command fcitx5-remote -c >/dev/null 2>&1
            end
        end

        __fcitx_sudo_command $argv
        set -l sudo_status $status
        __fcitx_sudo_restore
        return $sudo_status
    end
end
