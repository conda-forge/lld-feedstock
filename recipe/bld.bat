@echo on

mkdir build
cd build

set CC=cl.exe
set CXX=cl.exe

:: code is looking in the wrong place for MSVC_DIA_SDK_DIR, would be fixed by
:: https://github.com/llvm/llvm-project/commit/8cfab5de13a8ec3a2ffccb1b94b0165512a33552
:: https://github.com/llvm/llvm-project/commit/e32936aef4a2e7da471e84b72d3be3499adf0a21
echo %VSINSTALLDIR%

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DLLVM_INCLUDE_TESTS=OFF ^
    %SRC_DIR%/lld
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --target install
if %ERRORLEVEL% neq 0 exit 1
