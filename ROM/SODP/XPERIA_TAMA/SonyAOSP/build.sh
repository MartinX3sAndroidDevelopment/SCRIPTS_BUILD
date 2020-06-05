#!/usr/bin/env bash
#
# Copyright (c) 2019 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    echo "####SET VARIABLES START####"
    build_cache=/media/martin/extLinux/developer/android/cache/sonyAOSP/10 #CustomROM out dir
    build_out=/media/martin/extLinux/developer/android/out/sonyAOSP/10
    current_dir=$(pwd)
    customROM_dir=/home/developer/android/rom/sonyAOSP/10
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_sonyAOSP() {
    echo "####SONY AOSP BUILD START####"
    cd ${customROM_dir}
    source ${customROM_dir}/build/envsetup.sh

    echo "####$1 Sim START####"
    case "$1" in
        "XZ2_SS")
            product_name=aosp_h8216
            lunch ${product_name}-userdebug
        ;;
        "XZ2C_SS")
            product_name=aosp_h8314
            lunch ${product_name}-userdebug
        ;;
        "XZ3_SS")
            product_name=aosp_h8416
            lunch ${product_name}-userdebug
        ;;
        *)
            echo "Unknown Option $1 in build_sonyAOSP()"
            exit 1 # die with error code 9999
    esac

    make installclean # Clean build while saving the buildcache.

    make -j$((`nproc`+1)) dist

    cp ${build_cache}/dist/${product_name}-ota-eng.martin.zip ${build_out}/$(date +%Y-%m-%d_%H-%M-%S)_sonyAOSP_$1.zip
    echo "####$1 Sim END####"
    echo "####SONY AOSP BUILD END####"
}

# exit script immediately if a command fails or a variable is unset
set -eu

echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh

functions_init

set_variables

functions_create_folders ${build_cache}
functions_create_folders ${build_out}

functions_test_repo_up_to_date

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_sonyAOSP XZ2_SS
build_sonyAOSP XZ2C_SS
build_sonyAOSP XZ3_SS

echo "Output ${build_out}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

set +eu

exit 0
