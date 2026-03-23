# TODO anywhere abbr (abbr --add T --position anywhere '| rg -s')
function replace_then_execute
  if set --query prompt_count
    set -l new_command ( \
      commandline \
        | sed 's/ N$/; terminal-notifier -message "Command finished"/g' \
        | sed 's/ G / | rg -S /g' \
    )
    if [ "$NVIM" ]
      set new_command (echo $new_command | sed 's/ V$/ | nvr \'+call buffer#init_pager()\' --remote-wait -/g')
    else
      set new_command (echo $new_command | sed 's/ V$/ | '"$PAGER"'/g')
    end
    commandline -r $new_command

    set prompt_count (expr $prompt_count + 1)
  end

  commandline -f execute
end
