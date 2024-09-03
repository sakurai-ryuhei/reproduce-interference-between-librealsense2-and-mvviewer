#!/usr/bin/env bash

set -ex

sudo apt update
sudo apt install -y \
    build-essential \
    lld \
    git \
    curl \
    software-properties-common

sudo pip install cmake==3.26.3

directory_path_of_this_script=$(dirname $(readlink -f "$0"))
$directory_path_of_this_script/librealsense2_installer/install_librealsense2.sh
$directory_path_of_this_script/mvviewer_installer/install_mvviewer.sh
