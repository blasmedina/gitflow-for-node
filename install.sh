#!/bin/bash

INSTALL_PATH='/usr/local/bin/gfn'

rm $INSTALL_PATH
ln -s "$(pwd)/gfn.sh" $INSTALL_PATH
