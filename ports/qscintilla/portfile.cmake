vcpkg_download_distfile(ARCHIVE
    URLS "https://www.riverbankcomputing.com/static/Downloads/QScintilla/2.13.4/QScintilla_src-2.13.4.tar.gz"
    FILENAME "QScintilla-2.13.4.tar.gz"
    SHA512 591379f4d48a6de1bc61db93f6c0d1c48b6830a852679b51e27debb866524c320e2db27d919baf32576c2bf40bba62e38378673a86f22db9839746e26b0f77cd
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-static.patch
)

vcpkg_find_acquire_program(PYTHON3)

# Add python3 to path
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    OPTIONS
        CONFIG+=build_all
        CONFIG-=hide_symbols
        DEFINES+=SCI_NAMESPACE
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_install_qmake(
        RELEASE_TARGETS release
        DEBUG_TARGETS debug
    )
else()
    vcpkg_install_qmake()
endif()

file(GLOB HEADER_FILES ${SOURCE_PATH}/src/Qsci/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/Qsci)

if (VCPKG_TARGET_IS_WINDOWS AND (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic))
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/Qsci/qsciglobal.h
        "#if defined(QSCINTILLA_DLL)"
        "#if 1"
    )
endif()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
