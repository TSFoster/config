function a
  if set --query argv[1]
    if test $argv[1] = 'kill'; and set --query argv[2]
      kill -9 (ps (pgrep -xP 1 abduco) | awk '/ '$argv[2..]' /{print $1; exit}')
    else if test $argv[1] = clear
      command abduco | awk '/+/ { print $5 }' | xargs -I '{}' command abduco -a '{}'
    else
      abduco -a $argv[1]
    end
  else
    command abduco | awk '/^ / { print $4 } /^+/ { print $5" (terminated)" } /^*/ { print $5" (connected)" }'
  end
end

complete -fc a -a '(ls ~/.abduco | sed \'s/@.*//\')'
complete --command=a --short-option=c --long-option=clear --description='Clear all exited sessions'
complete --command=a --short-option=k --long-option=kill --description='Kill given session'
