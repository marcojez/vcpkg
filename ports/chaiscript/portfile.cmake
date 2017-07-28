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
    REF v6.0.0
    SHA512 612c175b9ee357512addcbe9ce0e2b9c34c40a45b5be85a3f75e2c0d391bc845996e2559c401e4899088b3e641c6c5b34af233bf2fd48d4de4531ea2815e2a96
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/chaiscript_config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DBUILD_MODULES=On
            -DBUILD_SAMPLES=Off
            -DBUILD_TESTING=Off
            -DMULTITHREAD_SUPPORT_ENABLED=On
            -DRUN_FUZZY_TESTS=Off
            -DRUN_PERFORMANCE_TESTS=Off
            -DUNIT_TEST_LIGHT=On
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH "share/chaiscript/cmake")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/tools")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/chai.exe" "${CURRENT_PACKAGES_DIR}/tools/chai.exe")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/chai.exe" "${CURRENT_PACKAGES_DIR}/debug/tools/chai.exe")

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/chaiscript)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/chaiscript/LICENSE ${CURRENT_PACKAGES_DIR}/share/chaiscript/copyright)
