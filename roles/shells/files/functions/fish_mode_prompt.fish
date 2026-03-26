function fish_mode_prompt --description 'Sets the mode_color for the current mode'
  set --global mode_color normal
  set -q fish_color_normal
  and set --global mode_color $fish_color_normal
  switch $fish_bind_mode
    case default
      set mode_color $mode_color
      set -q fish_color_command
      and set mode_color $fish_color_command
    case insert
      set -q fish_color_error
      and set mode_color $fish_color_error
    case replace_one
      set -q fish_color_normal
      and set mode_color $fish_color_normal
    case replace
      set -q fish_color_comment
      and set mode_color $fish_color_comment
    case visual
      set -q fish_color_selection
      and set mode_color $fish_color_selection
  end
end
