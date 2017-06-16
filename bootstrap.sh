#!/bin/bash

set -euo pipefail

: ${DOTFILES_PATH:="$HOME/dotfiles"}
: ${DOTFILES_BRANCH:=master}

#=== Steps
#====================================================================================================
print_header() {
  {
    printf "\e[34m"
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

clone_or_update_repo() {
  local git_dir="$DOTFILES_PATH/.git"

  if [ -d "$git_dir" ]; then
    echo 'Updating repo...'

    if [ "$(git --git-dir="$git_dir" symbolic-ref --short HEAD 2> /dev/null)" != "master" ]; then
      echo 'Skip repo update. You are working on a non-master branch.'
      return
    fi

    if ! git --git-dir="$git_dir" diff --no-ext-diff --quiet --exit-code 2> /dev/null 2>&1; then
      echo 'Skip repo update. There are unstaged changes.'
      return
    fi

    if ! git --git-dir="$git_dir" diff-index --cached --quiet HEAD -- >/dev/null 2>&1; then
      echo 'Skip repo update. There are uncommited changes.'
      return
    fi

    git --git-dir="$git_dir" pull origin master
    git --git-dir="$git_dir" submodule sync
    echo 'done'
  elif ! [ -d "$DOTFILES_PATH" ]; then
    echo 'Cloning repo...'
    git clone --recursive https://github.com/sykwer/dotfiles.git --branch $DOTFILES_BRANCH $DOTFILES_PATH
    echo 'done'
  else
    echo 'Stop cloning repo. You are supposed to use ~/dotfiles directory for manage dotfiles. Please make directory ~/dotfiles.'
    exit 1
  fi
}

#=== EntryPoint
#====================================================================================================
main() {
  print_header
  clone_or_update_repo
}

main
