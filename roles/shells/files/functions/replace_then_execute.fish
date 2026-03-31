function replace_then_execute
  if set --query prompt_count
    set -l new_command ( \
      commandline \
        | sed 's/ N$/; terminal-notifier -message "Command finished"/g' \
        | sed 's/ G / | rg -S /g' \
    )
    set new_command (echo $new_command | sed 's/ V$/ | '"$PAGER"'/g')

    commandline -r $new_command

    set prompt_count (expr $prompt_count + 1)
  end

  commandline -f execute
end
