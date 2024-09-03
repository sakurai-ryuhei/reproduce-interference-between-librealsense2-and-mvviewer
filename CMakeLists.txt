cmake_minimum_required(VERSION 3.10)
project(mvviewer_and_librealsense2 VERSION 0.0.0 LANGUAGES CXX)

add_executable(main main.cpp)

find_package(realsense2 REQUIRED)
target_link_libraries(main realsense2::realsense2)

target_link_libraries(main MVSDK)
target_link_directories(main PUBLIC /opt/HuarayTech/MVviewer/lib)
target_include_directories(main SYSTEM PUBLIC /opt/HuarayTech/MVviewer/include)

target_compile_features(main PRIVATE cxx_std_20)
