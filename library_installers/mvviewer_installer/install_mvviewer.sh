#!/usr/bin/env bash

set -ex

directory_path_of_this_script=$(dirname $(readlink -f "$0"))
yes yes | sudo $directory_path_of_this_script/official_installer/MVviewer_Ver2.3.2_Linux_x86_Build20220401.run --nox11
