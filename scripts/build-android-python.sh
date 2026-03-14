#!/usr/bin/env bash
set -euo pipefail

ABI="${1:?missing abi}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PYTHON_VERSION="${PYTHON_VERSION:-3.12.6}"
PYTHON_VERSION_DOT="${PYTHON_VERSION_DOT:-3.12}"
ANDROID_API="${ANDROID_API:-21}"

if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
  echo "ANDROID_NDK_HOME is required" >&2
  exit 1
fi

BUILD_ROOT="${ROOT_DIR}/.build/android/${ABI}"
SRC_ARCHIVE="${ROOT_DIR}/.build/Python-${PYTHON_VERSION}.tgz"
SRC_DIR="${ROOT_DIR}/.build/Python-${PYTHON_VERSION}"
TOOLCHAIN="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin"

case "$ABI" in
  armv7)
    HOST="arm-linux-androideabi"
    TARGET="armv7a-linux-androideabi${ANDROID_API}"
    INCLUDE_DIR="${ROOT_DIR}/lib/cpython/include/android/armv7"
    LIB_DIR="${ROOT_DIR}/lib/cpython/lib/android/armv7/lib"
    ;;
  arm64-v8a)
    HOST="aarch64-linux-android"
    TARGET="aarch64-linux-android${ANDROID_API}"
    INCLUDE_DIR="${ROOT_DIR}/lib/cpython/include/android/arm64-v8a"
    LIB_DIR="${ROOT_DIR}/lib/cpython/lib/android/arm64-v8a/lib"
    ;;
  x86)
    HOST="i686-linux-android"
    TARGET="i686-linux-android${ANDROID_API}"
    INCLUDE_DIR="${ROOT_DIR}/lib/cpython/include/android/x86"
    LIB_DIR="${ROOT_DIR}/lib/cpython/lib/android/x86/lib"
    ;;
  x86_64)
    HOST="x86_64-linux-android"
    TARGET="x86_64-linux-android${ANDROID_API}"
    INCLUDE_DIR="${ROOT_DIR}/lib/cpython/include/android/x86_64"
    LIB_DIR="${ROOT_DIR}/lib/cpython/lib/android/x86_64/lib"
    ;;
  *)
    echo "Unsupported ABI: $ABI" >&2
    exit 1
    ;;
esac

mkdir -p "${ROOT_DIR}/.build"

if [[ ! -f "$SRC_ARCHIVE" ]]; then
  curl -L "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz" -o "$SRC_ARCHIVE"
fi

if [[ ! -d "$SRC_DIR" ]]; then
  tar -xzf "$SRC_ARCHIVE" -C "${ROOT_DIR}/.build"
fi

rm -rf "$BUILD_ROOT"
mkdir -p "$BUILD_ROOT"
pushd "$SRC_DIR" >/dev/null

make distclean >/dev/null 2>&1 || true

export CC="${TOOLCHAIN}/${TARGET}-clang"
export CXX="${TOOLCHAIN}/${TARGET}-clang++"
export AR="${TOOLCHAIN}/llvm-ar"
export RANLIB="${TOOLCHAIN}/llvm-ranlib"
export READELF="${TOOLCHAIN}/llvm-readelf"
export STRIP="${TOOLCHAIN}/llvm-strip"

CONFIG_SITE_FILE="${BUILD_ROOT}/config.site"
cat > "$CONFIG_SITE_FILE" <<EOF
ac_cv_file__dev_ptmx=yes
ac_cv_file__dev_ptc=no
ac_cv_func_getaddrinfo=yes
ac_cv_buggy_getaddrinfo=no
EOF

export CONFIG_SITE="$CONFIG_SITE_FILE"

./configure \
  --host="$HOST" \
  --build="$(./config.guess)" \
  --disable-shared \
  --disable-test-modules \
  --with-pkg-config=no \
  --without-ensurepip \
  --with-build-python="$(command -v python3)"

make -j"$(getconf _NPROCESSORS_ONLN)" libpython${PYTHON_VERSION_DOT}.a Parser/pgen Programs/_freeze_module

mkdir -p "$LIB_DIR" "$INCLUDE_DIR"
cp "libpython${PYTHON_VERSION_DOT}.a" "$LIB_DIR/"
find Include -type f -name "*.h" -exec cp --parents {} "$INCLUDE_DIR" \;
cp pyconfig.h "$INCLUDE_DIR/pyconfig.h"
"$STRIP" --strip-debug "$LIB_DIR/libpython${PYTHON_VERSION_DOT}.a" || true

popd >/dev/null
