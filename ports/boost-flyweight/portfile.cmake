# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/flyweight
    REF boost-1.72.0
    SHA512 86c09e92dbf046770d6683ae42b23bf6e37c8b9f39da69adc000d1ad36ddede40a846bd4ae5bcf08cc1ae20291b5dd33fa1fd9f882007f339e2587f1980178fb
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
