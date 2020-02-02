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
    cd ${customROM_dir}

    echo "####Executing SODP repo_update.sh START####"
    # Executing the SODP patches
    bash ${customROM_dir}/repo_update.sh
    echo "####Executing SODP repo_update.sh END####"

    echo "####Modifying prebuild kernel script START####"
    #TODO: Try to remove this. Only Cherry-picks making clang script usable
    cd ${customROM_dir}/kernel/sony/msm-4.14/common-kernel
    git fetch https://github.com/MarijnS95/kernel-sony-msm-4.14-common aosp/LA.UM.7.1.r1 && git cherry-pick 393d89bb76be8727447276dd59b6febec4a9bad8 50481c1f171e25c0d49dda5f2e682f37f9b78cf5 80bb0d306d1084cf28e4144d6e6ec6eeaf45a346 774e0f952b5dd3fd152794490c166a1443d78a04

    # We only want to build for tama
    sed -i -e 's/loire tone yoshino nile ganges tama kumano/tama/g' ${customROM_dir}/kernel/sony/msm-4.14/common-kernel/build-kernels-clang.sh
    echo "####Modifying prebuild kernel script END####"

    echo "####Prebuild kernel START####"
    cd ${customROM_dir}/kernel/sony/msm-4.14/common-kernel
    bash ${customROM_dir}/kernel/sony/msm-4.14/common-kernel/build-kernels-clang.sh
    echo "####Prebuild kernel END####"
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_sonyAOSP() {
    echo "####SONY AOSP BUILD START####"
    cd ${customROM_dir}
    source ${customROM_dir}/build/envsetup.sh

    echo "####$1 Sim START####"
    case "$1" in
        "XZ2_SS")
            product_name=akari
            dualsim=false
            lunch aosp_h8216-userdebug
        ;;
        "XZ2C_SS")
            product_name=apollo
            dualsim=false
            lunch aosp_h8314-userdebug
        ;;
        "XZ3_SS")
            product_name=akatsuki
            dualsim=false
            lunch aosp_h8416-userdebug
        ;;
        "XZ2_DS")
            product_name=akari
            dualsim=true
            lunch aosp_h8266-userdebug
        ;;
        "XZ2C_DS")
            product_name=apollo
            dualsim=true
            lunch aosp_h8324-userdebug
        ;;
        "XZ3_DS")
            product_name=akatsuki
            dualsim=true
            lunch aosp_h9436-userdebug
        ;;
        *)
            echo "Unknown Option $1 in build_sonyAOSP()"
            exit 1 # die with error code 9999
    esac

    make installclean # Clean build while saving the buildcache.

    if ${dualsim}; then
        partitions="boot vendor"
        make -j$((`nproc`+1)) bootimage vendorimage
    else
        partitions="boot dtbo system userdata vbmeta vendor"
        make -j$((`nproc`+1))
    fi

    for partition in ${partitions}; do
        cp ${build_cache}/target/product/${product_name}/${partition}.img ${build_out}/$1/
    done
    echo "####$1 Sim END####"
    echo "####SONY AOSP BUILD END####"
}

# exit script immediately if a command fails
set -e

echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh

functions_init

set_variables

functions_create_folders ${build_cache}
functions_create_folders ${build_out}
functions_create_folders ${build_out}/XZ2_SS
functions_create_folders ${build_out}/XZ2C_SS
functions_create_folders ${build_out}/XZ3_SS
functions_create_folders ${build_out}/XZ2_DS
functions_create_folders ${build_out}/XZ2C_DS
functions_create_folders ${build_out}/XZ3_DS

functions_test_repo_up_to_date

functions_clean_builds ${build_out}/XZ2_SS
functions_clean_builds ${build_out}/XZ2C_SS
functions_clean_builds ${build_out}/XZ3_SS
functions_clean_builds ${build_out}/XZ2_DS
functions_clean_builds ${build_out}/XZ2C_DS
functions_clean_builds ${build_out}/XZ3_DS

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_sonyAOSP XZ2_SS
build_sonyAOSP XZ2_DS
build_sonyAOSP XZ2C_SS
build_sonyAOSP XZ2C_DS
build_sonyAOSP XZ3_SS
build_sonyAOSP XZ3_DS

functions_compress_builds ${build_out}/XZ2_SS sonyAOSP_XZ2_SS
functions_compress_builds ${build_out}/XZ2C_SS sonyAOSP_XZ2C_SS
functions_compress_builds ${build_out}/XZ3_SS sonyAOSP_XZ3_SS
functions_compress_builds ${build_out}/XZ2_DS sonyAOSP_XZ2_DS
functions_compress_builds ${build_out}/XZ2C_DS sonyAOSP_XZ2C_DS
functions_compress_builds ${build_out}/XZ3_DS sonyAOSP_XZ3_DS

functions_clean_builds ${build_out}/XZ2_SS
functions_clean_builds ${build_out}/XZ2C_SS
functions_clean_builds ${build_out}/XZ3_SS
functions_clean_builds ${build_out}/XZ2_DS
functions_clean_builds ${build_out}/XZ2C_DS
functions_clean_builds ${build_out}/XZ3_DS

echo "Output ${build_out}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

# because "set -e" is used above, when we get to this point, we know
# everything worked fine.
set +e

exit 0
