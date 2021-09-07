set -g fish_prompt_pwd_dir_length 0
set -g VIRTUAL_ENV_DISABLE_PROMPT 1
set -g green (set_color green)
set -g red (set_color red)
set -g normal (set_color normal)
set -g yellow (set_color -o yellow)
set -g blue (set_color -o blue)
set -g grey (set_color -d white)
set -g orange (set_color FFA500)

# Check if in git repository
function _is_in_git_repository
  echo (command git rev-parse --git-dir 2>/dev/null)
end

function _git_branch_name
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function _is_git_dirty
  echo (command git status -s --ignore-submodules=dirty 2> /dev/null)
end

function _git_project
  echo (git rev-parse --show-toplevel 2>/dev/null)
end

function _string_length 
  echo $argv[1] \
    | string replace -ra '\e\[[^m]*m' '' \
    | string replace -ra '[^[:print:]]' '' \
    | string length
end

function display_venv
  if [ $VIRTUAL_ENV ]
    if [ $VIRTUAL_ENV_NAME ]
      set venv_name $VIRTUAL_ENV_NAME
    else
      set venv_name (basename $VIRTUAL_ENV)
    end
    echo -n -s "🐍 " $green $venv_name $normal " "
  end
end

function display_vault
  if [ $AWS_VAULT ]
    echo -n -s '🔓 ' $yellow $AWS_VAULT  $normal ' '
  end
end

function display_cwd
  if [ (_is_in_git_repository) ]
    set cwd (string replace (git rev-parse --show-toplevel 2>/dev/null) "" $PWD)
    set cwd (string trim --left --chars "/" $cwd)
  else
    set cwd (prompt_pwd)
  end
  echo -n -s $blue $cwd $normal " "
end

function git_branch
  set -l branch (_git_branch_name)
  if test (string length "$branch") -gt 20 
    set reduced_branch (string sub --length=18 $branch)..
  else 
    set reduced_branch $branch
  end
  echo $reduced_branch
end

function display_git
  if [ (_is_in_git_repository) ]
    if [ (_is_git_dirty) ]
      set branch_color (set_color -oi FFA500)
    else
      set branch_color (set_color FFA500)
    end
    set -l branch (git_branch)
    set -l project (_git_project)
    set -l project_name (basename $project)
    echo -n -s "(" $branch_color $branch $normal ") " $orange $project_name $normal "/"
    # echo -n -s $grey "on " $project_name '/' $branch $dirty $normal ' '
  end
end

function display_prompt_char
  if test $last_status = 0
    set prompt_color $green
  else
    set prompt_color $red
    set code "$last_status "
  end
  echo -n -s $prompt_color $code "λ " $normal
end

function display_host_user
  set -l user (whoami)
  set -l host (hostname)
  echo -n -s "💻 " $grey $user '@' $host $normal ' '
end

function display_left_prompt
  set -l cwd (display_cwd)
  set -l venv (display_venv)
  set -l vault (display_vault)
  set -l git (display_git)
  set -l host_user (display_host_user)
  # echo -s $git $cwd $venv $vault $host_user

  set -l possible_prompts \
    (echo -n -s $git $cwd $venv $vault $host_user) \
    (echo -n -s $git $cwd $venv $vault) \
    (echo -n -s $git $cwd $vault) \
    (echo -n -s $cwd $vault) \
    (echo -n -s $cwd)

  for prompt in $possible_prompts
    if test (_string_length $prompt) -lt $COLUMNS
      echo $prompt
      return
    end
  end
  echo $cwd
end


function fish_prompt
  set -g last_status $status
  set -l left_prompt (display_left_prompt)
  set -l prompt_char (display_prompt_char)
  echo -s $left_prompt
  echo -n -s $prompt_char
end
