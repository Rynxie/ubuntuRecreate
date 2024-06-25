# ~/.zshrc

# Turn off the default prompt
prompt off

# Add custom directories to the PATH
export PATH=$PATH:~/bin/
export PATH=$PATH:~/.local/bin/
export GTK_THEME=Catppuccin-Mocha-Standard-Mauve-Dark:dark

MOR='%F{magenta}'
CYAN='%F{cyan}'
RESET='%f'

function git_branch_name()
{
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo '- ('$branch')'
  fi
}

# Enable substitution in the prompt.
setopt prompt_subst

# Config for prompt. PS1 synonym.
prompt='%F{magenta}%n %F{cyan} -> %F{magenta}%1~ % %F{cyan}$(git_branch_name) # %f '
