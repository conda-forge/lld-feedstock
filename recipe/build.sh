mkdir build
cd build

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DLLVM_CONFIG_PATH=$BUILD_PREFIX/bin/llvm-config -DLLVM_TABLEGEN_EXE=$BUILD_PREFIX/bin/llvm-tblgen"
fi

if [[ "$target_platform" == osx-* ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DLLVM_HAVE_LIBXAR=0"
fi

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_OBJ_ROOT=${PREFIX} \
  -DLLVM_MAIN_INCLUDE_DIR=${PREFIX}/include \
  -DLLVM_CMAKE_PATH=${PREFIX}/lib/cmake/llvm \
  ${CMAKE_ARGS} \
  ../lld

make -j${CPU_COUNT}
make install
