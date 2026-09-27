function ssh_key_gen --description 'Generate an ed25519 SSH key in 1Password, copy the public key, and drop it into ~/.ssh'
  set --local options \
    (fish_opt --short=v --long=vault --required-val) \
    (fish_opt --short=h --long=help)
  argparse $options -- $argv

  if set --query _flag_help
    echo 'ssh_key_gen [-v | --vault VAULT] NAME [COMMENT]'
    echo '    Generate an ed25519 key as a 1Password "SSH Key" item titled NAME'
    echo '    (private key never touches disk), copy the public key to the'
    echo '    clipboard, and write it to ~/.ssh/NAME.pub. COMMENT, if given, is'
    echo '    saved as the item'"'"'s notes. VAULT defaults to Personal.'
    return 0
  end

  set --local name $argv[1]
  set --local comment $argv[2]

  if test -z "$name"
    echo 'ssh_key_gen: missing NAME, e.g. ssh_key_gen id_github' >&2
    return 1
  end

  set --local vault Personal
  set --query _flag_vault
  and set vault $_flag_vault

  set --local ssh_dir ~/.ssh
  set --local pub_path $ssh_dir/$name.pub

  if test -e $pub_path
    echo "ssh_key_gen: $pub_path already exists, aborting" >&2
    return 1
  end

  if op item get $name --vault=$vault >/dev/null 2>&1
    echo "ssh_key_gen: an item named '$name' already exists in the $vault vault" >&2
    return 1
  end

  mkdir -p $ssh_dir
  chmod 700 $ssh_dir

  set --local create_args --category='SSH Key' --title=$name --vault=$vault --ssh-generate-key=ed25519
  test -n "$comment"
  and set --append create_args notesPlain=$comment

  if not op item create $create_args >/dev/null
    echo 'ssh_key_gen: failed to create the 1Password item' >&2
    return 1
  end

  set --local pubkey (op read "op://$vault/$name/public key")
  if test -z "$pubkey"
    echo "ssh_key_gen: created '$name' in 1Password but could not read its public key back" >&2
    return 1
  end

  printf '%s\n' $pubkey > $pub_path
  chmod 644 $pub_path

  if test "$OS" = Mac
    printf '%s' $pubkey | pbcopy
  else if type -q wl-copy
    printf '%s' $pubkey | wl-copy
  else if type -q xclip
    printf '%s' $pubkey | xclip -selection clipboard
  else
    echo 'ssh_key_gen: no clipboard tool found, skipped copying the public key' >&2
  end

  echo "Created '$name' in the $vault vault, wrote $pub_path, and copied the public key"
end
