include(vcpkg_common_functions)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "qt5-winextras only support Windows.")
endif()

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

qt_modular_library(qtwinextras e50cb237359ce7a3bde6989ec4349fe67be3b4999092516e891bba12f0fb4acb9954de8e2f0171db0e849b7d3ef94bd80f77f81162afb239e49c6e2e0760343b)
