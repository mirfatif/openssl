#!/bin/bash
set -e
#set -x

# https://github.com/openssl/openssl.git

#export ANDROID_NDK=~/android-sdk/ndk-bundle

NDK()
{
	# ANDROID_STANDALONE_TOOLCHAIN
	TOOLCHAIN=/tmp/my-android-toolchain-${ARCH}-${API}

	# build toolchain, ARCH decides toolchain binaries to use, STL decides C++ API
	# Android API decides C (native) API i.e. libraries and headers to use
	[ -e  $TOOLCHAIN ] ||
	make_standalone_toolchain.py --arch $ARCH --stl=libc++ --api $API --install-dir $TOOLCHAIN

	# Add the standalone toolchain to the search path.
	export PATH=$TOOLCHAIN/bin:$PATH

	# set minimal rootfs of target OS (libraries and headers)
	export SYSROOT=$TOOLCHAIN/sysroot
}

NDK_64()
{
	export ARCH=arm64
	export HOST=aarch64-linux-android

	# api +22 doesn't work for static linking; clang (upto NDK r16) and gcc both
	# because Bionic "libc.a" hasn't been updated since then
	API=21
	NDK
}

NDK_32()
{
	export ARCH=arm
	export HOST=arm-linux-androideabi

	API=14
	NDK
}


ARM_GCC_BIONIC()
{
	export ARCH=arm
	export HOST=arm-linux-androideabi
}

ARM_GCC_GLIBC()
{
	export ARCH=arm
	export HOST=arm-linux-gnueabi
}

AARCH64_GCC_GLIBC()
{
	export ARCH=arm64
	export HOST=aarch64-linux-gnu
}

ARM_GCC_MUSL()
{
	TOOLCHAIN=/home/irfan/WorkDir/musl-cross-make/arm-linux-musleabi
	export SYSROOT=$TOOLCHAIN/arm-linux-musleabi
	export PATH=$TOOLCHAIN/bin:$PATH
	export ARCH=arm
	export HOST=arm-linux-musleabi
}

AARCH64_GCC_MUSL()
{
	TOOLCHAIN=/home/irfan/WorkDir/musl-cross-make/aarch64-linux-musl
	export SYSROOT=$TOOLCHAIN/aarch64-linux-musl
	export PATH=$TOOLCHAIN/bin:$PATH
	export ARCH=arm64
	export HOST=aarch64-linux-musl
}

SET_VAR()
{
	export CROSS_COMPILE="${HOST}-"
	export SUBARCH=$ARCH
	export CHOST=$HOST
}

NDK_CLANG_CONFIG()
{
	! which ${CROSS_COMPILE}clang-cpp &>/dev/null ||
	export CPP=${CROSS_COMPILE}clang-cpp
	export AS=${CROSS_COMPILE}clang
	export CC=${CROSS_COMPILE}clang
	export CXX=${CROSS_COMPILE}clang++
}

NDK_GCC_CONFIG()
{
	# Android doesn't like gcc much
	export CFLAGS="-D__ANDROID_API__=$API"
	export LDFLAGS="-D__ANDROID_API__=$API"
	export CXXFLAGS="-D__ANDROID_API__=$API"

}

NDK_AARCH64_CLANG_BIONIC()
{
	NDK_64
	SET_VAR
	NDK_CLANG_CONFIG
}

NDK_AARCH64_GCC_BIONIC()
{
	NDK_64
	SET_VAR
	NDK_GCC_CONFIG
}

NDK_ARM_CLANG_BIONIC()
{
	NDK_32
	SET_VAR
	NDK_CLANG_CONFIG
}

NDK_ARM_GCC_BIONIC()
{
	NDK_32
	SET_VAR
	NDK_GCC_CONFIG
}


unset CFLAGS LDFLAGS CXXFLAGS CPPFLAGS







#NDK_AARCH64_CLANG_BIONIC
#NDK_AARCH64_GCC_BIONIC
#AARCH64_GCC_GLIBC && SET_VAR
#AARCH64_GCC_MUSL && SET_VAR

#NDK_ARM_CLANG_BIONIC
#NDK_ARM_GCC_BIONIC
ARM_GCC_BIONIC && SET_VAR
#ARM_GCC_GLIBC && SET_VAR
#ARM_GCC_MUSL && SET_VAR


# Tell configure what flags Android requires
export CFLAGS="$CFLAGS -Wall"
#export CPPFLAGS="--sysroot=$SYSROOT"
#export CXXFLAGS="--sysroot=$SYSROOT"
#export CFLAGS="$CFLAGS --sysroot=$SYSROOT"
#export LDFLAGS="$LDFLAGS --sysroot=$SYSROOT"


# add extra headers and libraries directories
#SYSROOT_ADDITIONS=/usr/local
#export CFLAGS="$CFLAGS -I${SYSROOT_ADDITIONS}/include"
#export LDFLAGS="$LDFLAGS -L${SYSROOT_ADDITIONS}/lib"

# for (Android) dynamic compile
#export CFLAGS="$CFLAGS -fPIE -fPIC"
#export LDFLAGS="$LDFLAGS -pie"

# for static compile
export CFLAGS="$CFLAGS --static -static"
export LDFLAGS="$LDFLAGS --static -static"

#export PATH=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/:$PATH

./Configure linux-armv4 -static no-shared --cross-compile-prefix=arm-linux-gnueabi- &&
make clean &&
make all
#make install
