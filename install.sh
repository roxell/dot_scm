#!/bin/bash

reporoot=$(readlink -f $(dirname $0))

[[ -f install-lib ]] || curl -sSOL https://raw.githubusercontent.com/roxell/local-inst-lib/master/install-lib
source install-lib

install_files=(

    "$HOME/.gitconfig:${reporoot}/git/gitconfig"
    "$HOME/.gitignore:${reporoot}/git/gitignore"
    "$HOME/bin/git-loream:${reporoot}/git/git-loream"
)

mkdir -p ${HOME}/bin

python3 -m pip install --user b4

create_symlink

###############################################################################
# vim: set ts=4 sw=4 sts=4 et                                                 :
