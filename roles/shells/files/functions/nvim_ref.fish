function nvim_ref --description "Get visual selection or cursor context as file reference string"
    if not set -q NVIM
        echo "Not running in Neovim" >&2
        return 1
    end

    nvim --server "$NVIM" --remote-expr 'luaeval("require([[config.util]]).selection_ref()")'
end
