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

    if ! git --git-dir="$git_dir" -C "$DOTFILES_PATH" diff --no-ext-diff --quiet --exit-code 2> /dev/null 2>&1; then
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
    echo 'Stop cloning repo. You are supposed to use ~/dotfiles directory for manage dotfiles, but the directory is already used.'
    exit 1
  fi
}

fix_permission() {
  [ -d /usr/local ] || mkdir -p /usr/local
  [ "$(stat -f '%Su' /usr/local)" = "$(whoami)" ] && return

  echo 'Fixing permission of /usr/local...'
  sudo chown -R $(whoami) /usr/local
  echo 'done'
}

install_homebrew() {
  command -v 'brew' > /dev/null 2>&1 && return

  echo 'Installing homebrew...'
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
  echo 'done'
}

install_homebrew_cask() {
  command -v 'brew cask' > /dev/null 2>&1 && return

  echo 'Installing homebrew cask...'
  brew tap caskroom/cask
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
  $DOTFILES_PATH/provisioning/run.sh
  echo 'done'
}


#=== EntryPoint
#====================================================================================================
main() {
  print_header
  clone_or_update_repo
  fix_permission
  install_homebrew
  install_homebrew_cask
  install_ansible
  provision
}

main
