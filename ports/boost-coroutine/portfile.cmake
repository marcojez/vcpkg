# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular.cmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/coroutine
    REF boost-1.66.0
    SHA512 f42318076c1547797dd9427c47eb6a6dc5e2407f788d6e8c7e8b6092632238a6e33f1c4d02c25af00bb85f89c82a6f8f2d10911620b5d53cbc0bf931c7fdd160
    HEAD_REF master
)

boost_modular_build(SOURCE_PATH ${SOURCE_PATH})
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
