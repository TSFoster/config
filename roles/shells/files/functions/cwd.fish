function cwd
  if [ "$NVIM" ]
    set d (nvr --remote-expr 'getcwd()')
    echo $d
    [ "$argv[1]" = '--cd' ]; and cd $d
  else
    pwd
  end
end
