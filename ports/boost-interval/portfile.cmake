# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/interval
    REF boost-${VERSION}
    SHA512 00b01439e255bb6a8ca0f4e09992a3231abb079ba0237d6dd3db51cc9dc30d1fdba01281e03e76abe61981d17804203b8c27c8b51c1dcf048d68462da5e4590b
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
