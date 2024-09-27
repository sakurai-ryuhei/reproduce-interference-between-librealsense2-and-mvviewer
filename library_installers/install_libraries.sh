#!/usr/bin/env bash

set -ex

sudo apt update
sudo apt install -y \
    build-essential \
    lld \
    cmake \
    git \
    wget \
    curl \
    software-properties-common \
    libdw-dev

directory_path_of_this_script=$(dirname $(readlink -f "$0"))
$directory_path_of_this_script/librealsense2_installer/install_librealsense2.sh
$directory_path_of_this_script/mvviewer_installer/install_mvviewer.sh
