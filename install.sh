#!/bin/bash

reporoot=$(readlink -f $(dirname $0))

install_files=(

    "$HOME/.gitconfig:${reporoot}/git/gitconfig"
    "$HOME/.gitignore:${reporoot}/git/gitignore"
)

for target in ${install_files[@]}; do
    KEY=${target%%:*}
    VALUE=${target##*:}

    echo "Processing $VALUE"

    if [ ! -e $VALUE ]; then
        echo -e "\t$VALUE doesn't exist. Skipping"
        continue
    fi

    cur_source=$(readlink -e $KEY)
    if [ -z "$cur_source" ]; then
        echo -e "\tCreating symlink"
        mkdir -p $(dirname "$KEY")
        ln -s "$VALUE" "$KEY"
    elif [ "$cur_source" != "$VALUE" ]; then
        echo -e "\tThere's already a file in the way at $KEY"
        if [ -L $KEY ]; then
            echo "It's a symlink pointing at $cur_source"
        fi
        read -p "REPLY?\tDo you want to overwrite it (y/n)? "
        case $REPLY in
            'y')
                if [ ! -L $KEY ]; then
                    curdate=$(date +'%Y%m%d:%H%M%S')
                    echo -e "\tMoving original $KEY to $KEY.backup-$curdate"
                    mv "$KEY" "$KEY.backup-$curdate"
                else
                    echo "Removing original symlink"
                    rm $KEY
                fi
                echo -e "\tCreating symlink"
                ln -s "$VALUE" "$KEY"
                ;;
            'n')
                echo -e "\tDoing nothing to it then... suit your self"
                continue
                ;;
        esac
    else
        echo -e "\t$KEY is already pointing at $VALUE"
    fi
done

###############################################################################
# vim: set ts=4 sw=4 sts=4 et                                                 :
