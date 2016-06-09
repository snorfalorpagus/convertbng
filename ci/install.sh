#!/bin/bash
set -e -x
if [[ "$DOCKER_BUILD" == "TRUE" ]]; then
    docker pull $DOCKER_IMAGE
fi
sudo pip install pip --upgrade
sudo pip install --install-option="--no-cython-compile" cython
sudo pip install numpy
sudo pip install python-coveralls
sudo pip install nosexcover

if [[ "$OSX_BUILD" == "TRUE" ]]; then
    system_profiler SPSoftwareDataType | grep "System Version" | awk '{print $6}'
    otool -L $HOME/build/urschrei/convertbng/convertbng/liblonlat_bng.dylib
    # mkdir -p $HOME/build/urschrei/lonlat_bng/target/x86_64-apple-darwin/release/
    # cp $HOME/build/urschrei/convertbng/convertbng/liblonlat_bng.dylib $HOME/build/urschrei/lonlat_bng/target/x86_64-apple-darwin/release/ 
fi
cd $HOME/build/urschrei/convertbng && sudo pip install -e .
