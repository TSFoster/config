function fish_prompt
  set last_status $status

  set --query prompt_count; or set --global prompt_count 0
  set --query last_prompt; or set --global last_prompt -1

  set --query prompt_pids; or set --global prompt_pids
  begin
    count $prompt_pids
    and ps -p $prompt_pids
    and kill -TERM $prompt_pids
    and set prompt_pids
  end > /dev/null 2> /dev/null

  set pathinfofile /tmp/fish-prompt-path-(string replace -a '/' '%' $PWD)
  set gitinfofile /tmp/fish-prompt-git-(string replace -a '/' '%' $PWD)

  set project_path_color black
  set project_dir_color red
  set pwd_path_color $project_path_color
  set pwd_dir_color blue
  set docker_machine_color cyan
  set sshinfo_color green

  if test $last_status -eq 0
    set last_status_color normal
    set last_status ' '
  else
    set last_status_color red
    set last_status \u2524_$last_status
  end

  test -f $pathinfofile
  or echo -n \n\n(prompt_base_and_dir $PWD) > $pathinfofile

  test -f $gitinfofile
  or echo -n \n\n\n\n\n > $gitinfofile

  # For some reason it's unreliable doing this on the first prompt
  if test $prompt_count = 0
    begin
      $XDG_CONFIG_HOME/fish/bin/__fish_prompt_git_details $gitinfofile
      $XDG_CONFIG_HOME/fish/bin/__fish_prompt_path $pathinfofile
    end
  # Only do this once per prompt
  else if test $last_prompt -lt $prompt_count
    # Begin/end stops the "job x has finished" message
    begin
      $XDG_CONFIG_HOME/fish/bin/__fish_prompt_git_details $gitinfofile $fish_pid &
      set prompt_pids (jobs -lp | tail -n1)
      $XDG_CONFIG_HOME/fish/bin/__fish_prompt_path $pathinfofile $fish_pid &
      set prompt_pids $prompt_pids (jobs -lp | tail -n1)
    end
    set last_prompt $prompt_count
  end

  test "$COLUMNS" -gt 0 2> /dev/null
  and set first_line (set_color $last_status_color)(printf '%'$COLUMNS's' $last_status | tr \  \u2500 | tr _ \ )

  set --query SSH_CLIENT
  and set sshInfo " $USER@"(hostname)
  set sshinfo_length (string length "$sshInfo")

  set --query DOCKER_MACHINE_NAME
  and set machineName "[$DOCKER_MACHINE_NAME]"
  set dockerinfo_length (string length "$machineName")

  set pathinfo (cat $pathinfofile)
  set pathinfo_length (string length (string join '' $pathinfo))

  set gitinfo (cat $gitinfofile)
  set giticons ' '
  set gitcolors normal
  if test -n "$gitinfo[1]"
    set gitcolors $gitcolors green
    set giticons $giticons '('(string replace -r '^master|main$' '●' $gitinfo[1] | string replace -r '^feature/' '★' | string replace -r '^hotfix/' '⌁')')'

    test "$gitinfo[2]" = "STAGED"
    and set giticons $giticons +
    and set gitcolors $gitcolors red

    test "$gitinfo[3]" = "DIRTY"
    and set giticons $giticons …
    and set gitcolors $gitcolors red

    switch "$gitinfo[4]"
      case 'AHEAD'
        set giticons $giticons \u2191
        set gitcolors $gitcolors green
      case 'BEHIND'
        set giticons $giticons \u2193
        set gitcolors $gitcolors blue
      case 'AHEADBEHIND'
        set giticons $giticons \u2195
        set gitcolors $gitcolors red
    end

    test "$gitinfo[5]" = "STASHES"
    and set giticons $giticons '❖'
    and set gitcolors $gitcolors magenta
  end

  set gitinfo_length (string length (string join '' $giticons))

  set second_line (
    set_color $project_path_color
    echo -n "$pathinfo[1]"
    set_color $project_dir_color
    echo -n "$pathinfo[2]"
    set_color $pwd_path_color
    echo -n "$pathinfo[3]"
    set_color $pwd_dir_color
    echo -n "$pathinfo[4]"
    if test (count $giticons) -gt 0
      for i in (seq (count $giticons))
        set_color $gitcolors[$i]
        echo -n "$giticons[$i]"
      end
    end
    test "$COLUMNS" -gt 0 2> /dev/null
    and printf '%-'(expr $COLUMNS - $pathinfo_length - $gitinfo_length - $dockerinfo_length - $sshinfo_length - 1)'s' ' '
    set_color --bold $docker_machine_color
    echo -n "$machineName"
    set_color --bold $sshinfo_color
    echo -n "$sshInfo"
  )

  set third_line (set_color $mode_color)\u25b8(set_color normal)

  echo $first_line
  echo $second_line
  echo -n $third_line\ 
end
