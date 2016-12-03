#!/bin/bash

reporoot=$(readlink -f $(dirname $0))

[[ -f install-lib ]] || curl -sSOL https://raw.githubusercontent.com/roxell/local-inst-lib/master/install-lib
source install-lib

install_files=(

    "$HOME/.gitconfig:${reporoot}/git/gitconfig"
    "$HOME/.gitignore:${reporoot}/git/gitignore"
)

create_symlink

###############################################################################
# vim: set ts=4 sw=4 sts=4 et                                                 :
