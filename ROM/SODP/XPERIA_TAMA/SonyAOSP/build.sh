#!/usr/bin/env bash

function set_variables() {
    echo "####SET VARIABLES START####"
    build_cache=/media/extLinux/developer/android/cache/sonyAOSP/13 #CustomROM out dir
    build_out=/media/extLinux/developer/android/out/sonyAOSP/13
    customROM_dir=/home/developer/android/rom/sonyAOSP/13
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_sonyAOSP() {
    echo "####SONY AOSP BUILD START####"
    echo "####$1 Sim START####"
    functions_build_customROM_helper ${customROM_dir:?} "${1:?}"-userdebug

    cd ${customROM_dir:?}
    make -j$(nproc --ignore=2) dist # exclude 1 real & 1 hyperthreading core since the A13 build system uses much more RAM & dist creates a flashable zip
    mv ${build_cache}/dist/"${1:?}"-ota-eng.martin.zip ${build_out}/aosp-13-"$(date +%Y%m%d)"_"${2:?}".zip
    echo "####$1 Sim END####"
    echo "####SONY AOSP BUILD END####"
}

# exit script immediately if a command fails or a variable is unset
set -e

read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh

functions_init

set_variables

functions_create_folders ${build_cache:?}
functions_create_folders ${build_out:?}

functions_test_repo_up_to_date

functions_update_customROM ${customROM_dir:?}

add_custom_hacks

build_sonyAOSP aosp_h8216 akari # XZ2_SS
build_sonyAOSP aosp_h8314 apollo # XZ2C_SS
build_sonyAOSP aosp_h8416 akatsuki # XZ3_SS

echo "Output ${build_out:?}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

set +e

exit 0
