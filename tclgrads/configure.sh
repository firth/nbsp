#!/bin/sh

. ../configure.inc

savedir=`pwd`
cd tclgrads
./configure.sh
cd $savedir

sed -e "/@include@/s||$INCLUDE|" \
    -e "/@q@/s||$Q|g" \
    -e "/@INSTALL@/s||$INSTALL|" Makefile.in > Makefile
