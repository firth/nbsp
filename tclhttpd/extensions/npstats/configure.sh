#!/bin/sh

dirs=

. ../../../configure.inc

configure_default

for d in $dirs
do
  cd $d
  ./configure.sh
  cd ..
done
