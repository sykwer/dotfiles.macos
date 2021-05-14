#  General
#-----------------------------------------------
export LANG=ja_JP.UTF-8
export EDITOR=vim

export LSCOLORS='Gxfxcxdxbxegedabagacad'


#  Env vars for various paths
#-----------------------------------------------
# dotfiles
export DOTFILES_PATH="$HOME/dotfiles"

# golang
export GOPATH=$HOME/go

# android
# export ANDROID_HOME=/usr/local/opt/android-sdk

# anyenv
export ANYENV_DIR=$HOME/.anyenv

# tmux
# export TMUX_RESURRECT_SCRIPTS_PATH=~/.tmux/plugins/tmux-resurrect/scripts


#  Search path
#-----------------------------------------------
# local
export PATH=/usr/local/bin:$PATH

# sbin
export PATH=/usr/local/sbin:$PATH

# dotfiles
export PATH=$DOTFILES_PATH/bin:$PATH

# anyenv
export PATH=$ANYENV_DIR/bin:$PATH

# heroku
# export PATH=$PATH:/usr/local/heroku/bin

# gtkwave
export PATH=/Applications/gtkwave.app/Contents/Resources/bin/:$PATH

#  Git
#-----------------------------------------------
export GIT_MERGE_AUTOEDIT='no'

if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

source /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
# eval $(gdircolors ~/settings/dircolors-solarized)


# Command prompt
#-----------------------------------------------
GIT_PS1_SHOWDIRTYSTATE=true
export PS1='[\w$(__git_ps1 " (%s)")]\$ '


# golang
#-----------------------------------------------
export PATH=$PATH:$GOPATH/bin


#  Rails
#-----------------------------------------------
export DISABLE_SPRING=1


#  Anyenv
#-----------------------------------------------
eval "$(anyenv init -)"


# LLVM
#-----------------------------------------------
#To use the bundled libc++ please add the following LDFLAGS:
#  LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"

#llvm is keg-only, which means it was not symlinked into /usr/local,
#because macOS already provides this software and installing another version in
#parallel can cause all kinds of trouble.

#If you need to have llvm first in your PATH, run:
#  echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> /Users/sykwer/.bash_profile

#For compilers to find llvm you may need to set:
#  export LDFLAGS="-L/usr/local/opt/llvm/lib"
#  export CPPFLAGS="-I/usr/local/opt/llvm/include"

source ~/.bashrc
