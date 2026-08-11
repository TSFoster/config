function p
  set --local options \
    (fish_opt --short=d --long=delete) \
    (fish_opt --short=f --long=force) \
    (fish_opt --short=l --long=list) \
    (fish_opt --short=h --long=help)
  argparse $options -- $argv

  [ "$NVIM" ]
  and not status --is-command-substitution
  and not set --query _flag_help
  and not set --query _flag_list
  and not set --query _flag_delete
  and echo "Will not run nvim from within nvim" >&2
  and return 1

  if set --query _flag_help
    echo 'p -h | --help'
    echo '    This help message.'
    echo ''
    echo 'p'
    echo '    List currently running projects.'
    echo ''
    echo 'p -l | --list'
    echo '    List all projects.'
    echo ''
    echo 'p NAME [ PATH [ -f  --force ] ]'
    echo '    Start project NAME, optionally (force re-)setting project root. If the'
    echo '    function is called from within a command substitution, print the path'
    echo '    to the project.'
    echo ''
    echo 'p [ -d | --delete ] [ -f | --force ] NAME...'
    echo '    Delete project NAME. Use -f/--force to supress non-existence warnings.'
    return 0
  end

  set --query XDG_DATA_HOME; or set XDG_DATA_HOME $HOME/.local/share
  set --query P_HOME; or set P_HOME $XDG_DATA_HOME/p
  set --query P_SEARCH; or set P_SEARCH $P_HOME/search
  set --query P_PROJECTS; or set P_PROJECTS $P_HOME/projects

  mkdir -p $P_HOME
  touch $P_SEARCH $P_PROJECTS

  set --local separator '////' # '/' is the only character not allowed in a filename for any filesystem

  set --local projectNames
  set --local projectDirs

  for projectDef in (cat $P_PROJECTS)
    string match --regex --quiet '^(?<projectDir>.*)'$separator'(?<projectName>.*)$' -- $projectDef
    and set --query projectName
    and set --query projectDir
    and set projectNames $projectNames $projectName
    and set projectDirs $projectDirs $projectDir
  end

   set --local definedCount (count $projectNames)
   set --local definedIndexes (seq $definedCount)

  for searchDef in (cat $P_SEARCH)
    string match --regex --quiet '^(?<searchDir>.*)'$separator'(?<dirPrefix>.*)$' -- $searchDef
    and set --query searchDir
    and set --query dirPrefix
    and for dir in $searchDir/*
      set projectNames $projectNames $dirPrefix(basename $dir)
      set projectDirs $projectDirs $dir
    end
  end

  set --local indexes (seq (count $projectNames))

  if set -q _flag_list
    if status --is-command-substitution
      string join \n $projectNames
    else
      for i in $indexes
        echo (set_color --bold)$projectNames[$i](set_color normal): $projectDirs[$i]
      end
    end
    return 0
  end

  if set -q _flag_delete
    if [ (count $argv) -eq 0 ]; and not set -q _flag_force
      echo 'No project names given!' >&2
      return 1
    end
    set --local sedCmd
    for i in $definedIndexes
      contains $projectNames[$i] $argv
      and set sedCmd $sedCmd$i'd;'
      and echo Deleting $projectNames[$i] >&2
    end
    sed -i bak $sedCmd $P_PROJECTS
  end

  set --local projectName $argv[1]
  set --local projectDir $argv[2]

  # If p is run without arguments
  if not count $argv > /dev/null
    set --local running_projects
    for sock in $P_HOME/nvim-*.sock 2>/dev/null
      if test -S "$sock"
        set --local name (string match --regex 'nvim-(.*)\.sock$' (basename "$sock"))
        if test -n "$name[2]"
          if nvim --server "$sock" --remote-expr 'v:servername' >/dev/null 2>&1
            set -a running_projects $name[2]
          else
            rm -f "$sock"
          end
        end
      end
    end

    if test (count $running_projects) -eq 0
      echo 'No projects are currently running.'
      return 0
    end

    for p in $running_projects
      set --local path_msg ""
      set --local i (contains --index $p $projectNames)
      if test -n "$i"
        set path_msg ": $projectDirs[$i]"
      end
      echo (set_color --bold)$p(set_color normal)$path_msg
    end
    return 0
  end

  set --local i (contains --index $projectName $projectNames)
  test -n "$i"
  and set --local projectExists
  and test "$i" -le "$definedCount"
  and set --local projectDefined

  test -n "$projectDir"; and set --local dirGiven

  not set --query dirGiven
  and set --query projectExists
  and set projectDir $projectDirs[$i]

  set --query _flag_force
  and set --query dirGiven
  and not test -d $projectDir
  and mkdir -p $projectDir

  set --query dirGiven
  and set projectDir (realpath $projectDir)

  not test -d $projectDir
  and echo Had trouble with project directory >&2
  and return 1

  set --query projectExists
  and set --query projectDefined
  and set --query dirGiven
  and set --query _flag_force
  and sed -i bak $i'c'\\\n$projectDir$separator$projectName\n $P_PROJECTS

  not set --query projectDefined
  and set --query dirGiven
  and echo $projectDir$separator$projectName >> $P_PROJECTS

  set --query projectDefined
  and set --query dirGiven
  and not set --query _flag_force
  and echo "Project exists and is set to $projectDir. Use --force to overwrite project definition" >&2
  and return 1

  if status --is-command-substitution
    echo $projectDir
  else
    pushd $projectDir
    set --local sock "$P_HOME/nvim-$projectName.sock"
    if test -S "$sock"
      if not nvim --server "$sock" --remote-ui
        rm -f "$sock"
        nvim --listen "$sock" -c 'silent detach!'
      end
    else
      nvim --listen "$sock" -c 'silent detach!'
    end
    popd
  end

  return 0

end
