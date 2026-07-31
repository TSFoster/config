function nvim_selection --description "Get visual selection or cursor context from parent Neovim session as JSON"
    if not set -q NVIM
        echo '{"error": "Not running in Neovim"}' >&2
        return 1
    end

    nvim --server "$NVIM" --remote-expr 'luaeval("require([[config.util]]).selection_json()")'
end
