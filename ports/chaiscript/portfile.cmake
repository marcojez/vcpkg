SET(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
if (VCPKG_CRT_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static linking of the CRT is not yet supported.")
endif()
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ChaiScript/ChaiScript
    REF 9a670d79fc6be0446bbe5d7573ad26faf0786144
    SHA512  e9012c5289bd017dce5f51138759b88b5f4d1e4d5ad722692673d7c0f2d70b85706d0de90f73739a382891c93e164785f80a09da67fcb6a43734670b12fe2161
    HEAD_REF develop
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/chaiscript-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DBUILD_MODULES=On
            -DBUILD_SAMPLES=Off
            -DBUILD_TESTING=Off
            -DMULTITHREAD_SUPPORT_ENABLED=On
            -DRUN_FUZZY_TESTS=Off
            -DRUN_PERFORMANCE_TESTS=Off
            -DUNIT_TEST_LIGHT=On
            -DBUILD_IN_CPP17_MODE=On
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/chaiscript")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/chaiscript")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/chaiscript")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/tools/chaiscript")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/chai.exe" "${CURRENT_PACKAGES_DIR}/tools/chaiscript/chai.exe")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/chai.exe" "${CURRENT_PACKAGES_DIR}/debug/tools/chaiscript/chai.exe")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/chaiscript)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/chaiscript)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/chaiscript/LICENSE ${CURRENT_PACKAGES_DIR}/share/chaiscript/copyright)
