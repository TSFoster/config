function nvim_register --description "Get a register's content from parent Neovim session (default: register 0, the yank register)"
    if not set -q NVIM
        echo "Not running in Neovim" >&2
        return 1
    end

    set -l reg $argv[1]
    if test -z "$reg"
        set reg 0
    end

    if not string match -qr '^[0-9a-zA-Z"%#*+\-/:._=]$' -- "$reg"
        echo "nvim_register: invalid register '$reg'" >&2
        return 1
    end

    nvr --servername "$NVIM" --remote-expr "getreg('$reg')"
end
