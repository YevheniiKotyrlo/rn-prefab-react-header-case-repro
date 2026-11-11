# rn-prefab-react-header-case-repro

ReproducerApp on React Native `0.90.0-nightly-20261111-1273ca128` (`main` at 1273ca128), with one C++ file in the app's native library that includes a header from the react-android AAR's prefab through each of its two top folders, `react/` and `React/`, built with clang's `-Wnonportable-system-include-path`:

- `ReproducerApp/android/app/build.gradle` points `externalNativeBuild` at `src/main/jni/CMakeLists.txt`.
- `ReproducerApp/android/app/src/main/jni/CMakeLists.txt` is React Native's default app setup plus `case/HeaderCase.cpp` and `-Wnonportable-system-include-path`, which React Native's `-Werror` makes an error.
- `HeaderCase.cpp` includes `react/renderer/components/view/ViewProps.h` and `React/View.h`.

## Reproduce

On a volume that compares names without case, as Windows' do by default:

```bash
./reproduce.sh
```

It runs `yarn install` and `./gradlew :app:externalNativeBuildDebug -PreactNativeArchitectures=arm64-v8a` in `ReproducerApp`, prints the compiler's errors and each folder of the prefab include directory the build used whose name is `react` in any case, with what it holds, and exits 1 while an include fails as non-portable, 0 once the build succeeds, 2 when another step fails.

Expected: both includes resolve as spelled. Seen: the include directory holds one folder, `React`, with the umbrella headers and the `react/` tree in it, and `HeaderCase.cpp:1:10: error: non-portable path to file '<React/renderer/components/view/ViewProps.h>'; specified path differs in case from file name on disk [-Werror,-Wnonportable-system-include-path]`.
