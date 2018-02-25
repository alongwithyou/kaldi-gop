#!/bin/sh

utils/check_dependencies.sh || exit
cd src/
mkdir build && cd build
cmake .. && make
