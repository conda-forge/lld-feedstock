mkdir build
cd build

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DLLVM_CONFIG_PATH=$BUILD_PREFIX/bin/llvm-config -DLLVM_TABLEGEN_EXE=$BUILD_PREFIX/bin/llvm-tblgen"
fi

if [[ "${target_platform}" == osx-* ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DLLVM_ENABLE_LIBCXX=ON"
fi

if [[ "${target_platform}" == linux-ppc64le ]]; then
    # From https://github.com/conda-forge/zig-feedstock/blob/ec81ca731c700f20602a92e48f9013cb3a4ff889/recipe/build_scripts/cross-zig-linux-ppc64le.sh#L14-L22
    # Add ld.bfd for relocation issue
    # CRITICAL: Remove conda's -fno-plt which breaks PowerPC64LE!
    # Conda's default flags include -fno-plt which disables PLT usage
    # -fno-plt forces direct branches (R_PPC64_REL24) which truncate at ±16MB
    # For PowerPC64LE large binaries, we NEED PLT for unlimited function call range
    # Remove -fno-plt and add -mcmodel=medium for TOC-relative addressing
    export CFLAGS="${CFLAGS//-fno-plt/} -fuse-ld=bfd -mcmodel=medium"
    export CXXFLAGS="${CXXFLAGS//-fno-plt/} -fuse-ld=bfd -mcmodel=medium"
    export LDFLAGS="${LDFLAGS} -fuse-ld=bfd"
fi

cmake -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_OBJ_ROOT=${PREFIX} \
  -DLLVM_MAIN_INCLUDE_DIR=${PREFIX}/include \
  ${CMAKE_ARGS} \
  ../lld

cmake --build . -- -j${CPU_COUNT}
cmake --install .
