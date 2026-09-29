function ssh_host_add --description 'Add a 1Password "Server" item tagged ssh-host and drop its ~/.ssh/config.d/hosts-NAME file, without re-running make ssh'
  set --local options \
    (fish_opt --short=v --long=vault --required-val) \
    (fish_opt --short=H --long=hostname --required-val) \
    (fish_opt --short=u --long=user --required-val) \
    (fish_opt --short=p --long=port --required-val) \
    (fish_opt --short=i --long=identity-file --required-val) \
    (fish_opt --short=j --long=proxy-jump --required-val) \
    (fish_opt --short=f --long=field --required-val --multiple-vals) \
    (fish_opt --short=h --long=help)
  argparse $options -- $argv

  if set --query _flag_help
    echo 'ssh_host_add [-v | --vault VAULT] [-H | --hostname HOSTNAME] [-u | --user USER]'
    echo '             [-p | --port PORT] [-i | --identity-file KEYNAME]'
    echo '             [-j | --proxy-jump HOST] [-f | --field LABEL=VALUE ...] NAME'
    echo '    Create a 1Password "Server" item titled NAME, tagged ssh-host, with'
    echo '    the given fields, then write ~/.ssh/config.d/hosts-NAME directly so'
    echo '    it'"'"'s usable immediately (make ssh will re-render it identically'
    echo '    the next time it runs). KEYNAME, if it matches an existing'
    echo '    ~/.ssh/KEYNAME.pub (e.g. one made by ssh_key_gen), resolves to that'
    echo '    path; otherwise it'"'"'s written as-is. -f/--field sets any other ssh'
    echo '    config keyword (IdentitiesOnly, ProxyCommand, ForwardAgent, ...) by'
    echo '    giving it a 1Password custom field named after the keyword.'
    echo '    VAULT defaults to Personal.'
    return 0
  end

  set --local name $argv[1]

  if test -z "$name"
    echo 'ssh_host_add: missing NAME, e.g. ssh_host_add --hostname example.com my-server' >&2
    return 1
  end

  set --local vault Personal
  set --query _flag_vault
  and set vault $_flag_vault

  set --local ssh_dir ~/.ssh
  set --local config_dir $ssh_dir/config.d
  set --local safe_name (string replace --all --regex '[^A-Za-z0-9_.-]' '_' -- $name)
  set --local host_config_path $config_dir/hosts-$safe_name

  if test -e $host_config_path
    echo "ssh_host_add: $host_config_path already exists, aborting" >&2
    return 1
  end

  if op item get $name --vault=$vault >/dev/null 2>&1
    echo "ssh_host_add: an item named '$name' already exists in the $vault vault" >&2
    return 1
  end

  mkdir -p $config_dir
  chmod 700 $config_dir

  set --local create_args --category=Server --title=$name --vault=$vault --tags=ssh-host
  set --query _flag_hostname
  and set --append create_args url=$_flag_hostname
  set --query _flag_user
  and set --append create_args username=$_flag_user
  set --query _flag_port
  and set --append create_args "Port[text]=$_flag_port"
  set --query _flag_identity_file
  and set --append create_args "IdentityFile[text]=$_flag_identity_file"
  set --query _flag_proxy_jump
  and set --append create_args "ProxyJump[text]=$_flag_proxy_jump"
  for field in $_flag_field
    set --local label (string split --max=1 -- = $field)[1]
    set --local value (string split --max=1 -- = $field)[2]
    set --append create_args (string join '' -- "$label" '[text]=' "$value")
  end

  if not op item create $create_args >/dev/null
    echo 'ssh_host_add: failed to create the 1Password item' >&2
    return 1
  end

  set --local lines "Host $name"
  set --query _flag_hostname
  and set --append lines "	HostName $_flag_hostname"
  set --query _flag_user
  and set --append lines "	User $_flag_user"
  set --query _flag_port
  and set --append lines "	Port $_flag_port"
  if set --query _flag_identity_file
    set --local safe_key (string replace --all --regex '[^A-Za-z0-9_.-]' '_' -- $_flag_identity_file)
    set --local key_path $ssh_dir/$safe_key.pub
    if test -e $key_path
      set --append lines "	IdentityFile $key_path"
    else
      set --append lines "	IdentityFile $_flag_identity_file"
    end
  end
  set --query _flag_proxy_jump
  and set --append lines "	ProxyJump $_flag_proxy_jump"
  for field in $_flag_field
    set --local label (string split --max=1 -- = $field)[1]
    set --local value (string split --max=1 -- = $field)[2]
    set --append lines "	$label $value"
  end

  printf '%s\n' "# Managed by Ansible (roles/ssh) — do not edit by hand." \
    "# Generated from 1Password \"Server\" item \"$name\" tagged \"ssh-host\"." \
    $lines > $host_config_path
  chmod 600 $host_config_path

  echo "Created '$name' in the $vault vault and wrote $host_config_path"
end
