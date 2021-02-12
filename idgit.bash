#!/usr/bin/env bash

function _idgit_check_globals {
  local global_files=( --system  --global  )
  local warn_if_set=( email name )

  local useConfigOnly_set=""

  for scope in "${global_files[@]}"; do

    for name in "${warn_if_set}"; do
      if [[ ! -z "$(git config $scope --includes user.${name})" ]]; then
        echo "WARNING: idgit found $name in $scope - This may lead to your identity leaking across accounts. See https://github.com/matthewstrasiotto/idgit for details."
      fi

    done
    [[ "$(git config $scope --includes user.useConfigOnly)" == "true" ]] && useConfigOnly_set="1"

  done

  if [[ -z "$useConfigOnly_set" ]]; then
    echo "WARNING: user.useConfigOnly not set. This may lead to your identity leaking across accounts."
    echo "Consider setting: git config --global user.useConfigOnly true"
  fi
}

function _idgit_check_remote_email_private {
  local email="$1"

  local remote="$(git remote -v | grep '(push)' | cut -f2 | cut -d' ' -f1)"

  # Use V as delim
  local url_pattern='sV(www\.)?([-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4})\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)V\2Vg'
  local remote_host="$(echo "$remote" | sed -nE "$url_pattern")"


  if [[ $remote_host == "github.com" ]]; then
    if [[ ! "$email" =~ '.*@users\.noreply\.github.com' ]]; then
      echo "Warning - github email not of form @users.noreply.github.com , you may want to see the following:" 1>&2
      echo "https://docs.github.com/en/github/setting-up-and-managing-your-github-user-account/blocking-command-line-pushes-that-expose-your-personal-email-address" 1>&2
    fi

  fi
}

function idgit {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/idgit"
  [[ ! -d "$config_dir" ]] && mkdir -p "$config_dir"
  
  local USAGE=$(cat << EOF
  Usage: 
    ${FUNCNAME[0]} <profile>
    ${FUNCNAME[0]} --help | -h

  Sets the local git configuration according to the contents of ${config_dir}/profile.alias

  Structure profile.alias like so:

  ---
  # Lines beginning with # ignored
  user.name
  user.email
  credentials.name (optional)
  ---

  For example:

  ---
  # github.alias
  Matthew Strasiotto
  39424834+matthewstrasiotto@users.noreply.github.com
  matthewstrasiotto
  ---

  ${FUNCNAME[0]} github

EOF
  )


  if [ "$#" -ne 1 ]; then
    echo "$USAGE" 1>&2
    return 1
  fi

  local choice="$1"

  if [[ "$choice" == "--help" ]] || [[ "$choice" == "-h" ]]; then
    echo "$USAGE"
    return 0
  fi

  local git_name=""
  local git_email=""
  local git_user=""


  if [[ ! -f "$config_dir/$choice.alias" ]]; then
    echo "$choice.alias not found in $config_dir" 1>&2
    echo "$USAGE" 1>&2 
    return 1
  fi

  while read -r line; do
    # ignore comments
    if [[ ! "${line:0:1}" == "#" ]]; then
      
      # order is user, email
      [[ -z "$git_name" ]] && git_name="$line" && continue
      [[ -z "$git_email" ]] && git_email="$line" && continue
      
      [[ -z "$git_user" ]]  && git_user="$line" && continue
      # if both vars are set, stop reading
      break
    fi

  done < "$config_dir/$choice.alias"


  if [[ -z "$git_name" ]] || [[ -z "$git_email" ]]; then
    echo "Author name or email missing." 1>&2
    echo "$USAGE" 1>&2
    return 1
  fi

  git config --local user.name "$git_name"
  git config --local user.email "$git_email"

  [[ ! -z "$git_user" ]] && git config --local credentials.user "$git_user"

  _idgit_check_remote_email_private "$git_email"

  return 0
}



function _idgit_complete() {
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/idgit"

    local IFS=$'\n'
    local cur="${2}" && shift

    local suggestions=( $(compgen -W "$(ls $config_dir | sed -nE 's/(.*)\.alias/\1/p' 2> /dev/null)" -- "${cur}") )

    COMPREPLY=( ${COMPREPLY[@]:-} ${suggestions[@]:-} )

    return 0
}


function _idgit_install() {
  echo "Create ~/.idgit.bash :"
  
  [[ ! -f ~/.idgit.bash ]] && curl -fsSL https://raw.githubusercontent.com/matthewstrasiotto/idgit/HEAD/idgit.bash > ~/.idgit.bash
  
  echo "Update $HOME/.ssh/config :"

  local to_append='[[ -f ~/.idgit.bash ]] && . ~/.idgit.bash'
  local destination_file="$HOME/.bashrc"

  echo " - $to_append"
  
  if [[ ! -e "$destination_file" ]]; then
    echo "\n" >> "$destination_file"
  fi
  local linenums="$(sed -n "\,^${to_append},=" "$destination_file")"

  if [[ ! -z "$linenums" ]]; then
    echo "   - Already exists: lines #$linenums"
    return 0
  fi
  
  echo "${to_append}" >> "$destination_file"
}

if [[ -z "$INSTALL_IDGIT" ]]; then
  _idgit_install
fi

complete -F _idgit_complete idgit
