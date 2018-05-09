#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zaphoyd/websocketpp
    REF 19cad9925f83d15d7487c16f0491f4741ec9f674
    SHA512 7027975c434c38e182130da7185d3dc2e7777bf69ebfc8e4df5d9d8c66157afed1ff59217d23d1b39a05794d2692f97acb147be3592cdc92a6f322458ae42f4e
    HEAD_REF develop
)

#vcpkg_apply_patches(
#    SOURCE_PATH ${SOURCE_PATH}
#    PATCHES
#        ${CMAKE_CURRENT_LIST_DIR}/openssl_110.patch
#)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/websocketpp)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/websocketpp/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/websocketpp/COPYING ${CURRENT_PACKAGES_DIR}/share/websocketpp/copyright)

# Copy the header files
file(COPY "${SOURCE_PATH}/websocketpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.hpp")

set(PACKAGE_INSTALL_INCLUDE_DIR "\${CMAKE_CURRENT_LIST_DIR}/../../include")
set(WEBSOCKETPP_VERSION 0.7.0)
configure_file(${SOURCE_PATH}/websocketpp-config.cmake.in "${CURRENT_PACKAGES_DIR}/share/websocketpp/websocketpp-config.cmake" @ONLY)
#configure_file(${SOURCE_PATH}/websocketpp-configVersion.cmake.in "${CURRENT_PACKAGES_DIR}/share/websocketpp/websocketpp-configVersion.cmake" @ONLY)
