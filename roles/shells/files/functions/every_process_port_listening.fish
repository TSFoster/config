function every_process_port_listening
  if [ $OS == 'Mac' ]
    sudo lsof -iTCP -sTCP:LISTEN -iUDP -n -P
  else
    netstat -tunapl
  end
end
