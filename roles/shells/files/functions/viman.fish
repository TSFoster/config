function viman --wraps=man --description 'Open manpage in new tab in nvim'
  set entry $argv[1]
  if man -w $entry 2>&1 > /dev/null
    nvr +"tabe +Man\\ $entry|only"
  else
    echo "no manual entry for $entry"
  end
end
