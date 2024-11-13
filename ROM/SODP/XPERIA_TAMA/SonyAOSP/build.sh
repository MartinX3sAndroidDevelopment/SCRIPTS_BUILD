#!/usr/bin/env bash

function set_variables() {
    echo "####SET VARIABLES START####"
    aosp_version=15
    build_out=/out
    customROM_dir=/code
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_sonyAOSP() {
    echo "####SONY AOSP BUILD START####"
    echo "####$1-$2 Sim START####"
    functions_build_customROM_helper ${customROM_dir:?} "${1:?}"-"${2:?}"-userdebug

    cd ${customROM_dir:?}
    echo "Log build to ${build_out}/aosp-${aosp_version}_""${3:?}""-build.log"
    make -j dist > ${build_out}/aosp-${aosp_version}_"${3:?}"-build.log
    mv out/dist/"${1:?}"-ota-*.zip ${build_out}/aosp-${aosp_version}-"$(date +%Y%m%d)"_"${3:?}".zip
    echo "####$1-$2 Sim END####"
    echo "####SONY AOSP BUILD END####"
}

# TODO Temp until the tama changes got upstreamed to SODP
function functions_update_customROM_WORKAROUND() {
    echo "####CustomROM UPDATE START####"
    cd "${1:?}"/.repo/local_manifests || exit
    git reset --hard
    git pull

    cd "${1:?}" || exit
    repo forall -vc "git reset --hard"

    repo sync -c -j8 --force-sync --no-tags --no-clone-bundle --optimized-fetch --prune
    ./apply_patch.sh

    repo prune # Remove unneeded elements to save space and time.
    echo "####CustomROM UPDATE END####"
}

# exit script immediately if a command fails or a variable is unset
set -e

source TOOLS/functions.sh

functions_init

set_variables

functions_create_folders ${build_out:?}

# functions_update_customROM ${customROM_dir:?} # TODO Temp deactivated until the tama changes got upstreamed to SODP
functions_update_customROM_WORKAROUND ${customROM_dir:?}  # TODO Temp until the tama changes got upstreamed to SODP


add_custom_hacks

build_sonyAOSP aosp_h8216 ap3a akari # XZ2_SS
build_sonyAOSP aosp_h8314 ap3a apollo # XZ2C_SS
build_sonyAOSP aosp_h8416 ap3a akatsuki # XZ3_SS

functions_success "Sony AOSP"

set +e

exit 0
