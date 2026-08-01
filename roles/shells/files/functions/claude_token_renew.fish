function claude_token_renew --description "Regenerate the Claude Code OAuth token and store it in 1Password"
    set -l options (fish_opt --short=s --long=skip-setup)
    argparse $options -- $argv
    or return

    set -l vault Personal
    set -l title "Claude Code OAuth Token"

    if not set -q _flag_skip_setup
        echo "Running 'claude setup-token' — approve access in the browser, then copy the printed token."
        claude setup-token
    end

    read -l -s -P "Paste the token printed above: " token
    set token (string trim -- $token)
    if test -z "$token"
        echo "No token entered, aborting." >&2
        return 1
    end

    set -l expires (date -v+1y +%Y-%m-%d)

    if op item get $title --vault=$vault >/dev/null 2>&1
        op item edit $title --vault=$vault "credential=$token" "expires=$expires" >/dev/null
    else
        op item create --category="API Credential" --title=$title --vault=$vault "credential=$token" "expires=$expires" >/dev/null
    end

    echo "Stored in 1Password: $vault/$title (expires $expires)"
end
