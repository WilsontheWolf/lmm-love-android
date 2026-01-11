#!/bin/env fish
# To build Lovely:
# cargo build --package liblovely --target aarch64-linux-android --release && cargo build --package liblovely --target x86_64-linux-android --release
# 
# If you somehow get 32bit working cargo build --package liblovely --target armv7-linux-androideabi --release && cargo build --package liblovely --target i686-linux-android --release

export android_sdk=$HOME/Android/Sdk
export lovely=$HOME/projects/lovely-injector
fish_add_path -P $android_sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin/

function build -a 1 2 3 4
	echo
	echo Building for $1...
	make clean

	make HOST_LUA="luajit" "HOST_CC=clang $4" HOST_CFLAGS=-D_CRT_SECURE_NO_WARNINGS CC=clang CROSS=$2- "STATIC_CC=$2$3-clang -fPIC" "DYNAMIC_CC=$2$3-clang -fPIC" "TARGET_AR=llvm-ar rcus" TARGET_SYS=Linux TARGET_LD=$2$3-clang TARGET_LDFLAGS=-fuse-ld=lld TARGET_SONAME=libluajit.so CCDEBUG=-g "GIT_RELVER=cp ../.relver luajit_relver.txt" "LD=$android_sdk/build-tools/36.0.0/$2-ld" LIBS="./liblovely-$2.a" amalg -j16

	rm android/$1 -rf
	mkdir android/$1 

	cp src/libluajit.so android/$1/libluajit.so
	cp src/luajit.h android/$1/luajit.h
	cp -r src/jit android/$1/jit 

	echo "create android/$1/libluajit.a
	addlib src/libluajit.a
	addlib src/liblovely-$2.a
	save
end
" | ar -M
end

function setupLovely -a comp lovelyComp
	if test -z "$lovelyComp"
		set -f lovelyComp $comp
	end
	rm ./src/liblovely-$comp.a 2> /dev/null
	ln -s $lovely/target/$lovelyComp/release/liblovely.a ./src/liblovely-$comp.a
end

# Reset and apply patches
git checkout HEAD -- src/
rm src/lovely.h
git apply -v --directory=love/src/jni/LuaJIT-2.1 $lovely/crates/liblovely/luajit.patch


setupLovely x86_64-linux-android
setupLovely aarch64-linux-android
# setupLovely armv7a-linux-androideabi armv7-linux-androideabi
# setupLovely i686-linux-android

build x86_64 x86_64-linux-android 21
build arm64-v8a aarch64-linux-android 21
# build armeabi-v7a armv7a-linux-androideabi 21 -m32
# build x86 i686-linux-android 16 -m32

