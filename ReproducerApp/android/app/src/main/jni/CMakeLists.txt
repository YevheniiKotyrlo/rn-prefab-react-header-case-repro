cmake_minimum_required(VERSION 3.13)

project(appmodules)

include(${REACT_ANDROID_DIR}/cmake-utils/ReactNative-application.cmake)

target_sources(${CMAKE_PROJECT_NAME} PRIVATE case/HeaderCase.cpp)
target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE -Wnonportable-system-include-path)
