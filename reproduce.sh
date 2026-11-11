#!/usr/bin/env bash
# Exit 1 while ReproducerApp's C++ include of a react-android prefab header fails as non-portable, because the prefab's React/ and react/ are one folder on this volume; 0 once it builds; 2 when another step fails.
set -u

here="$(cd "$(dirname "$0")" && pwd)"
app="${here}/ReproducerApp"
nonportable="specified path differs in case from file name on disk"

system="$(uname -sm)"
if ! node_version="$(node --version 2>&1)"; then
    echo "step failed: node --version: ${node_version}"
    exit 2
fi
if ! java_version="$(java -version 2>&1)"; then
    echo "step failed: java -version: ${java_version}"
    exit 2
fi
echo "${system}, node ${node_version}, ${java_version%%$'\n'*}"

if ! install_output="$(cd "${app}" && yarn install --frozen-lockfile --non-interactive 2>&1)"; then
    printf '%s\n' "${install_output}"
    echo "step failed: yarn install"
    exit 2
fi
if ! react_native_version="$(cd "${app}" && node -p 'require("react-native/package.json").version' 2>&1)"; then
    echo "step failed: reading react-native's version: ${react_native_version}"
    exit 2
fi
echo "react-native ${react_native_version}"

echo "== ./gradlew :app:externalNativeBuildDebug -PreactNativeArchitectures=arm64-v8a"
build_output="$(cd "${app}/android" && ./gradlew --no-daemon --console=plain :app:externalNativeBuildDebug -PreactNativeArchitectures=arm64-v8a 2>&1)"
build_status=$?
compiler_lines="$(grep -E "^C/C\+\+: .*HeaderCase\.cpp:[0-9]+:[0-9]+: |^BUILD (SUCCESSFUL|FAILED)" <<<"${build_output}")"
sed -E 's#^C/C\+\+: .*/(ReproducerApp/)#C/C++: \1#' <<<"${compiler_lines}"
prefab_include="$(grep -oE -m 1 "[^ ]*/react-android-[^ /]*/prefab/modules/reactnative/include" <<<"${build_output}")"
if [[ -n "${prefab_include}" ]]; then
    echo "== folders named react in any case in ${prefab_include#*/transformed/}"
    for entry in "${prefab_include}"/*; do
        name="${entry##*/}"
        if [[ -d "${entry}" && "${name,,}" == "react" ]]; then
            listing=""
            for child in "${entry}"/*; do
                listing+="${child##*/} "
            done
            echo "${name}/: ${listing% }"
        fi
    done
fi

if [[ "${build_status}" -eq 0 ]]; then
    echo "SUMMARY: ReproducerApp builds: the prefab's React/ and react/ includes resolve as spelled"
    exit 0
fi
if grep -qF "${nonportable}" <<<"${build_output}"; then
    echo "SUMMARY: the react-android prefab's React/ and react/ are one folder on this volume, so an include spelled the other way fails -Wnonportable-system-include-path"
    exit 1
fi
printf '%s\n' "${build_output}" | tail -n 40
echo "SUMMARY: the build failed for another reason (exit ${build_status})"
exit 2
