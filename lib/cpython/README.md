# Prebuilt CPython Layout

This directory stores prebuilt CPython static libraries and headers used by `linc_cpython`.

Expected Android layout:

- `lib/cpython/include/android/armv7/`
- `lib/cpython/include/android/arm64-v8a/`
- `lib/cpython/include/android/x86/`
- `lib/cpython/include/android/x86_64/`
- `lib/cpython/lib/android/armv7/lib/libpython3.12.a`
- `lib/cpython/lib/android/arm64-v8a/lib/libpython3.12.a`
- `lib/cpython/lib/android/x86/lib/libpython3.12.a`
- `lib/cpython/lib/android/x86_64/lib/libpython3.12.a`

The GitHub Actions workflow `android-prebuilt.yml` populates this layout.
