#!/bin/bash

if [ ! -d "${QNX_TARGET}" ]; then
    echo "QNX_TARGET is not set. Exiting..."
    exit 1
fi

rm -rf build/ install/

for arch in armv7 aarch64 x86_64; do
#for arch in aarch64; do

    if [ "${arch}" == "aarch64" ]; then
        CPUVARDIR=aarch64le
        CPUVAR=aarch64le
    elif [ "${arch}" == "armv7" ]; then
        CPUVARDIR=armle-v7
        CPUVAR=armv7le
    elif [ "${arch}" == "x86_64" ]; then
        CPUVARDIR=x86_64
        CPUVAR=x86_64
    else
        echo "Invalid architecture. Exiting..."
        exit 1
    fi

    echo "CPU set to ${CPUVAR}"
    echo "CPUVARDIR set to ${CPUVARDIR}"

    export CPUVARDIR=${CPUVARDIR}
    export CPUVAR=${CPUVAR}
    export ARCH=${arch}

    if [ -e CMakeCache.txt ]; then
      rm CMakeCache.txt
    fi
    mkdir -p build/${CPUVARDIR}
    cd build/${CPUVARDIR}
    cmake --log-level=TRACE \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
        -DCMAKE_TOOLCHAIN_FILE=../../qnx.nto.toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=../../install/${CPUVARDIR} \
        ../.. || exit 1

    make -j $(command nproc 2>/dev/null || echo 12) || exit 1
    make install

    cd ../../

done
