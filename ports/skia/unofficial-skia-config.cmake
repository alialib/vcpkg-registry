if(NOT TARGET unofficial::skia::skia)
    function(z_vcpkg_skia_get_link_libraries out_var path libraries)
        set(libs "")
        foreach(lib IN LISTS libraries)
            if(lib MATCHES [[^/|^(dl|m|pthread)$|^-framework ]])
                list(APPEND libs "${lib}")
            else()
                string(MAKE_C_IDENTIFIER "${out_var}_${lib}" lib_var)
                find_library("${lib_var}" NAMES "${lib}" NAMES_PER_DIR PATH "${path}")
                mark_as_advanced("${lib_var}")
                if(${lib_var})
                    list(APPEND libs "${${lib_var}}")
                else()
                    message(WARNING "Omitting '${lib}' from link libraries.")
                endif()
            endif()
        endforeach()
        set("${out_var}" "${libs}" PARENT_SCOPE)
    endfunction()

    # Compute the installation prefix relative to this file.
    get_filename_component(z_vcpkg_skia_root "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(z_vcpkg_skia_root "${z_vcpkg_skia_root}" PATH)
    get_filename_component(z_vcpkg_skia_root "${z_vcpkg_skia_root}" PATH)
    if(z_vcpkg_skia_root STREQUAL "/")
        set(z_vcpkg_skia_root "")
    endif()

    function(z_vcpkg_skia_find_and_add_library name)
        add_library(unofficial::skia::${name} UNKNOWN IMPORTED)
        set_target_properties(unofficial::skia::${name} PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${z_vcpkg_skia_root}/include/skia"
        )

        find_library(z_vcpkg_skia_${name}_lib_release NAMES ${name} ${name}.dll PATHS "${z_vcpkg_skia_root}/lib" NO_DEFAULT_PATH)
        find_library(z_vcpkg_skia_${name}_lib_debug NAMES ${name} ${name}.dll PATHS "${z_vcpkg_skia_root}/debug/lib" NO_DEFAULT_PATH)
        mark_as_advanced(z_vcpkg_skia_${name}_lib_release z_vcpkg_skia_${name}_lib_debug)
        set(z_vcpkg_skia_lib_release ${z_vcpkg_skia_${name}_lib_release})
        set(z_vcpkg_skia_lib_debug ${z_vcpkg_skia_${name}_lib_debug})

        set(z_vcpkg_skia_config_debug "\$<CONFIG:Debug>")
        if(NOT z_vcpkg_skia_lib_debug)
            set(z_vcpkg_skia_config_debug "0")
        endif()

        z_vcpkg_skia_get_link_libraries(
            z_vcpkg_skia_${name}_link_libs_release
            "${z_vcpkg_skia_root}/lib;${z_vcpkg_skia_root}/debug/lib"
            "@SKIA_DEP_REL@"
        )
        set(z_vcpkg_skia_link_libs_release ${z_vcpkg_skia_${name}_link_libs_release})
        set_target_properties(unofficial::skia::${name} PROPERTIES
            IMPORTED_CONFIGURATIONS RELEASE
            IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
            IMPORTED_LOCATION_RELEASE "${z_vcpkg_skia_lib_release}"
            INTERFACE_COMPILE_DEFINITIONS "\$<\$<NOT:${z_vcpkg_skia_config_debug}>:@SKIA_DEFINITIONS_REL@>"
            INTERFACE_LINK_LIBRARIES "\$<LINK_ONLY:\$<\$<NOT:${z_vcpkg_skia_config_debug}>:${z_vcpkg_skia_link_libs_release}>>"
        )

        if(z_vcpkg_skia_lib_debug)
            z_vcpkg_skia_get_link_libraries(
                z_vcpkg_skia_${name}_link_libs_debug
                "${z_vcpkg_skia_root}/debug/lib;${z_vcpkg_skia_root}/lib"
                "@SKIA_DEP_DBG@"
            )
            set(z_vcpkg_skia_link_libs_debug ${z_vcpkg_skia_${name}_link_libs_debug})
            set_property(TARGET unofficial::skia::${name} APPEND PROPERTY
                IMPORTED_CONFIGURATIONS DEBUG
            )
            set_target_properties(unofficial::skia::${name} PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
                IMPORTED_LOCATION_DEBUG "${z_vcpkg_skia_lib_debug}"
            )
            set_property(TARGET unofficial::skia::${name} APPEND PROPERTY
                INTERFACE_COMPILE_DEFINITIONS "\$<\$<CONFIG:Debug>:@SKIA_DEFINITIONS_DBG@>"
            )
            set_property(TARGET unofficial::skia::${name} APPEND PROPERTY
                INTERFACE_LINK_LIBRARIES "\$<LINK_ONLY:\$<\$<CONFIG:Debug>:${z_vcpkg_skia_link_libs_debug}>>"
            )
        endif()
    endfunction()

    z_vcpkg_skia_find_and_add_library(skia)
    z_vcpkg_skia_find_and_add_library(skparagraph)
    z_vcpkg_skia_find_and_add_library(skshaper)
    z_vcpkg_skia_find_and_add_library(sktext)

    unset(z_vcpkg_skia_find_and_add_library)
    unset(z_vcpkg_skia_config_debug)
    unset(z_vcpkg_skia_root)
endif()
