#!/bin/bash

set -e

# We need to ensure that brew is intalled
# install:
#  . git
#  . neovim
#  . tmux
#  . taskwarrior

echo "****************************************************************"
echo "*                         Linkux IT                            *"
echo "*                         =========                            *"
echo "*                                                              *"
echo "*                    Starting installation                     *"
echo "****************************************************************"
echo

unamestr=`uname`

if [[ "$unamestr" == 'Darwin' ]]; then
    which -s brew
    if [[ $? != 0 ]] ; then
        # Linkux IT :: Install Homebrew
        # https://github.com/mxcl/homebrew/wiki/installation
        /usr/bin/ruby -e "$(curl -fsSL https://raw.github.com/gist/323731)"
    else
        brew update
    fi

    if [ -n "$INSTALL_NEOVIM" ]; then
      echo "Linkux IT :: Install: Installing NeoVim"
      # install neovim
      which -s nvim
      if [[ $? != 0 ]] ; then
          brew tap neovim/homebrew-neovim
          brew install --HEAD neovim
      else
          brew reinstall --HEAD neovim
      fi
    fi

    which -s git || brew install git
    which -s vim || brew install vim
    which -s tmux || brew install tmux
    which -s task || brew install task
else
    sudo apt-get update
    sudo apt-get --assume-yes install git git-core python-dev python-pip python3-dev python3-pip vim tmux task

    if [ -n "$INSTALL_NEOVIM" ]; then
      echo "Linkux IT :: Install: Installing NeoVim"
      sudo add-apt-repository ppa:neovim-ppa/unstable
      sudo apt-get --assume-yes install neovim
    fi
fi

# First clone or update our dotfiles
if [ ! -d ~/.linkux-dev ]; then
  echo "Linkux IT :: Install: Cloning Repository"
  git clone https://github.com/linkux-it/linkux-dev.git ~/.linkux-dev
else
  echo "Linkux IT :: Update: Updating repository"
  cd ~/.linkux-dev && git pull
  cd
fi

# if exists and is not symlinks
if [ -n "$CONFIG_NEOVIM" ]; then
  echo "Linkux IT :: Install: Backup old ~/.nvimrc to ~/.nvimrc.old"
  if [ -f ~/.nvimrc ] && [ ! -L ~/.nvimrc ]; then
    mv ~/.nvimrc ~/.nvimrc.old
  fi
else
  if [ -f ~/.vimrc ] && [ ! -L ~/.vimrc ]; then
    echo "Linkux IT :: Install: Backup old ~/.vimrc to ~/.vimrc.old"
    mv ~/.vimrc ~/.vimrc.old
  fi
fi

# create symlinks for setups
if [ ! -f ~/.vimrc ]; then
  echo "Linkux IT :: Install: Linking Linkut IT config for vim and nvim"
  if [ -n "$CONFIG_NEOVIM" ]; then
    ln -s ~/.linkux-dev/vimrc ~/.nvimrc
  else
    ln -s ~/.linkux-dev/vimrc ~/.vimrc
  fi
fi

# Setting up neobundle
if [ ! -d ~/.vim/bundle ]; then
  echo "Linkux IT :: Install: Creating bundle directory for NeoBundle"
  if [ -n "$CONFIG_NEOVIM" ]; then
    mkdir -p ~/.nvim/bundle
  else
    mkdir -p ~/.vim/bundle
  fi
fi

if [ ! -d ~/.vim/bundle/neobundle.vim ]; then
  echo "Linkux IT :: Install:Cloning NeoBundle"
  git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
fi

echo "Linkux IT :: Install vim plugins"
if [ -n "$CONFIG_NEOVIM" ]; then
  nvim +NeoBundleInstall +qall
else
  vim +NeoBundleInstall +qall
fi

# Setup configs neovim, taskwarrior, tmux
