cmake_minimum_required(VERSION 3.10)
project(mvviewer_and_librealsense2 VERSION 0.0.0 LANGUAGES CXX)

# Download `backward-cpp` library to show stack trace on segfault.
include(FetchContent)
FetchContent_Declare(backward
    GIT_REPOSITORY https://github.com/bombela/backward-cpp
    URL_HASH 51f0700452cf71c57d43c2d028277b24cde32502
    SYSTEM
)
FetchContent_MakeAvailable(backward)

add_executable(main
    main.cpp
    ${CMAKE_SOURCE_DIR}/build/_deps/backward-src/backward.cpp
)

find_package(realsense2 REQUIRED)
target_link_libraries(main realsense2::realsense2)

target_link_libraries(main MVSDK)
target_link_directories(main PUBLIC /opt/HuarayTech/MVviewer/lib)
target_include_directories(main SYSTEM PUBLIC /opt/HuarayTech/MVviewer/include)

target_compile_features(main PRIVATE cxx_std_20)

# Configuration to show a nice stack trace.
target_link_libraries(main dw)
add_backward(main true)
