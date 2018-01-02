# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular.cmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/flyweight
    REF boost-1.66.0
    SHA512 4c0faaafe0143404d6eabc57ee5089840290c865ab00b7b3c81d4ab37c1603aaec77bc7f592e4566ed20786a14bc6bb9a6623384fdf6886168cac2696224c6df
    HEAD_REF master
)

boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
