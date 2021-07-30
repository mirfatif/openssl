#!/bin/bash -e

# void arm64, void amd64, ubuntu arm64

#sudo apt purge libssl*-dev
#sudo xbps-remove libressl-devel

#git pull -a
#git checkout OpenSSL_1_1_1-stable

#export CFLAGS='-static --static'
#LDFLAGS='-static --static'

# link libdl.a to avoid error:
#  libcrypto.a(dso_dlfcn.o): In function 'dlfcn_pathbyaddr':
#  dso_dlfcn.c: undefined reference to 'dladdr'
#export LDFLAGS='$LDFLAGS -L/usr/lib/aarch64-linux-gnu -ldl'

#export OPENSSL_STATIC=1

#./config

#./Configure -static no-shared --prefix=/usr/local linux-x86_64
./Configure -static no-shared --prefix=/usr/local --openssldir=/usr/etc/ssl linux-aarch64

make clean
make -j4

mkdir /usr/local/etc && sudo ln -s /usr/local/etc /usr/etc
make -j4 install_sw install_ssldirs
