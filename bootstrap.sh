#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

: ${DOTFILES_PATH:="$HOME/dotfiles"}
: ${DOTFILES_BRANCH:=master}

ARGS=('')
for a in "$@"; do
  ARGS=(${ARGS[@]} "$a")
done

#=== Utils
#==============================================================================================
compare_versions() {
  declare -a v1=(${1//./ })
  declare -a v2=(${2//./ })
  local i=""

  for (( i=${#v1[@]}; i<${#v2[@]}; i++ )); do
    v1[i]=0
  done

  for (( i=0; i<${#v1[@]}; i++ )); do
    if [[ -z ${v2[i]} ]]; then
      v2[i]=0
    fi

    if (( 10#${v1[i]} > 10#${v2[i]} )); then
      printf ">"
      return 0
    fi

    if (( 10#${v1[i]} < 10#${v2[i]} )); then
      printf "<"
      return 0
    fi
  done

  printf "="
}

#=== Steps
#====================================================================================================
print_header() {
  {
    printf "\e[33m"
    echo '--------------------------------------------------------------------------------'
    echo '                                                                                '
    echo '                 888          888     88888 888 888                             '
    echo '                 888          888    88888  888 888                             '
    echo '                 888          888    888        888                             '
    echo '             8888888  888888  888888 888888 888 888  888888  8888888            '
    echo '            8888 888 88888888 888    888    888 888 888  888 888                '
    echo '            888  888 888  888 888    888    888 888 88888888 88888888           '
    echo '            8888 888 88888888 88888  888    888 888 8888          888           '
    echo '             8888888  888888   88888 888    888 888  888888   8888888           '
    echo '                                                                                '
    echo '                         github.com/sykwer/dotfiles                             '
    echo '                                                                                '
    echo '--------------------------------------------------------------------------------'
    printf "\e[0m\n"
 } | sed -e 's/8/🔥/g'
}

check_os() {
  if [ "$(uname -s)" == "Darwin" ]; then
    if [ $(compare_versions "$(sw_vers -productVersion)" "10.9") == '<' ]; then
      echo "Sorry, this script is intended only for OS X 10.9.0+"
      exit 1
    fi
  else
    echo "Sorry, this script is intended only for OS X"
    exit 1
  fi
}

clone_or_update_repo() {
  local git_dir="$DOTFILES_PATH/.git"

  if [ -d "$git_dir" ]; then
    echo 'Updating repo...'

    if [ "$(git --git-dir="$git_dir" symbolic-ref --short HEAD 2> /dev/null)" != "master" ]; then
      echo 'skip (working on a non-master branch)'
      return
    fi

    if ! git --git-dir="$git_dir" diff --no-ext-diff --quiet --exit-code > /dev/null 2>&1; then
      echo 'skip (unstaged changes present)'
      return
    fi

    if ! git --git-dir="$git_dir" diff-index --cached --quiet HEAD -- > /dev/null 2>&1; then
      echo 'skip (uncommitted changes present)'
      return
    fi

    git --git-dir="$git_dir" pull origin master
    git --git-dir="$git_dir" submodule sync
    echo 'done'
  elif ! [ -d "$DOTFILES_PATH" ]; then
    echo 'Cloning repo...'
    git clone --recursive git://github.com/sykwer/dotfiles.git --branch $DOTFILES_BRANCH $DOTFILES_PATH
    echo 'done'
  fi
}

check_xcode_license_approved() {
  echo 'Agreeing to Xcode license...'

  local has_error=0

  if ! [[ "$(/usr/bin/xcrun clang 2>&1 || true)" =~ 'license' ]]; then
    echo 'skip (already approved)'
    return
  fi

  sudo expect -c '
    set timeout 3
    spawn xcodebuild -license
    expect {
      timeout { exit 2 }
      -exact "for more" {
        send "G"
        exp_continue
      }
      -exact "agree, print, cancel" {
        send "agree\n"
        exp_continue
      }
      -exact "You can view the license agreements" {
        exit 0
      }
    }
  ' > /dev/null || has_error=1

  [ $has_error -eq 1 ] && sudo xcodebuild -license

  echo 'done'
}

install_homebrew() {
  command -v 'brew' > /dev/null 2>&1 && return

  echo 'Installing homebrew...'
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
  echo 'done'
}

install_ansible() {
  command -v 'ansible' > /dev/null 2>&1 && return

  echo 'Installing ansible...'
  brew install ansible
  echo 'done'
}

provision() {
  echo 'Provisioning...'
  $DOTFILES_PATH/provisioning/run.sh ${ARGS[@]}
  echo 'done'
}

#=== EntryPoint
#====================================================================================================
main() {
  print_header
  check_os
  clone_or_update_repo
  check_xcode_license_approved
  install_homebrew
  install_ansible
  provision
}

main

