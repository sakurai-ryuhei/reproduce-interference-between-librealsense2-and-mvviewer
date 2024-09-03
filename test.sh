#!/usr/bin/env bash

set -ex

directory_path_of_this_script=$(dirname $(readlink -f "$0"))
rm $directory_path_of_this_script/build -rf
mkdir $directory_path_of_this_script/build
cd $directory_path_of_this_script/build
cmake ..
make
$directory_path_of_this_script/build/main
