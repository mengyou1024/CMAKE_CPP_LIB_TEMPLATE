if(DEFINED UTILS_CMAKE_INCLUDED)
    message(WARNING "Utils.cmake has already been included, not need include ${CMAKE_CURRENT_LIST_DIR}/Utils.cmake")
    return()
endif()
message(STATUS "First Include ${CMAKE_CURRENT_LIST_DIR}/Utils.cmake")
set(UTILS_CMAKE_INCLUDED TRUE)

#[[
    添加子目录的路径, 该函数会遍历目录下所有的文件夹, 如果存在CMakeLists.txt则添加至子目录的构建目录
    `add_subdirectory_path(path)`
    `path`: 子目录路径
]]
function(add_subdirectory_path path)
    file(GLOB SUBPATH "${path}/*")

    foreach(ITEM ${SUBPATH})
        if(ITEM MATCHES ".*\\.((rar)|(7z)|(zip))$")
            get_filename_component(ITEM_PATH ${ITEM} DIRECTORY)
            message(STATUS "Extrace File:${ITEM}")
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E tar xzf ${ITEM}
                WORKING_DIRECTORY ${ITEM_PATH}
            )
        endif()
    endforeach(ITEM ${SUBPATH})

    file(GLOB SUBPATH "${path}/*")

    foreach(ITEM ${SUBPATH})
        if(IS_DIRECTORY "${ITEM}" AND EXISTS "${ITEM}/CMakeLists.txt")
            file(RELATIVE_PATH ITEM_PATH ${CMAKE_CURRENT_SOURCE_DIR} ${ITEM})
            message(STATUS "Add Subdirectory: ${ITEM_PATH}")
            add_subdirectory(${ITEM_PATH})
        endif(IS_DIRECTORY "${ITEM}" AND EXISTS "${ITEM}/CMakeLists.txt")
    endforeach(ITEM ${SUBPATH})
endfunction(add_subdirectory_path path)

#[[
    添加clang-tidy检查, 该函数会在构建前检查代码规范
    `add_clang_tidy_pre_build(target_name)`
    `target_name`: 目标名称
]]
function(add_clang_tidy_pre_build target_name)
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        return()
    endif()

    # 查找clang-tidy可执行文件
    find_program(CLANG_TIDY_EXECUTABLE clang-tidy)

    if(CLANG_TIDY_EXECUTABLE)
        if(NOT CLANG_TIDY_FIND_ONCE)
            message(STATUS "Found clang-tidy: ${CLANG_TIDY_EXECUTABLE}")
            set(CLANG_TIDY_FIND_ONCE TRUE CACHE INTERNAL "Flag to ensure the message runs only once.")
        endif()
    else()
        if(NOT CLANG_TIDY_FIND_ONCE)
        message(WARNING "clang-tidy not found, use: `choco install llvm` or `sudo apt install llvm` to install clang-tidy")
            set(CLANG_TIDY_FIND_ONCE TRUE CACHE INTERNAL "Flag to ensure the message runs only once.")
        endif()
        return()
    endif()

    get_target_property(_target_sources ${target_name} SOURCES)
    set(_clang_tidy_src "")

    foreach(_item ${_target_sources})
        get_filename_component(_asb_path ${_item} ABSOLUTE)
        list(APPEND _clang_tidy_src ${_asb_path})
    endforeach(_item ${_target_sources})

    add_custom_command(
        TARGET ${target_name}
        PRE_BUILD
        COMMAND clang-tidy -p "${CMAKE_BINARY_DIR}" --warnings-as-errors=* -header-filter=.* ${_clang_tidy_src}
        COMMENT "Check for clang-tidy issues before building ${target_name}"
        VERBATIM
    )
endfunction(add_clang_tidy_pre_build target_name)

#[[
    解析源码树, 该函数会遍历目录下所有的文件夹, 并将源文件和头文件分别存储到指定的变量中
    `resolve_source_tree(SRC_PATH SRC_FILES INC_FILES INC_DIRS)`
    `SRC_PATH`: 源码树路径
    `SRC_FILES`: 源文件列表
    `INC_FILES`: 头文件列表
    `INC_DIRS`: 头文件目录列表
]]
function(resolve_source_tree SRC_PATH SRC_FILES INC_FILES INC_DIRS)
    set(SRC_SUFFIX_LIST ".cpp" ".c" ".cc" ".cxx")
    set(INC_SUFFIX_LIST ".h" ".hpp")

    set(SRC_SEARCH_LIST "")

    foreach(SUFFIX ${SRC_SUFFIX_LIST})
        list(APPEND SRC_SEARCH_LIST "${SRC_PATH}/*${SUFFIX}")
    endforeach(SUFFIX ${SRC_SUFFIX_LIST})

    set(INC_SEARCH_LIST "")

    foreach(SUFFIX ${INC_SUFFIX_LIST})
        list(APPEND INC_SEARCH_LIST "${SRC_PATH}/*${SUFFIX}")
    endforeach(SUFFIX ${INC_SUFFIX_LIST})

    file(GLOB_RECURSE _RET_SRC ${SRC_SEARCH_LIST})
    file(GLOB_RECURSE _RET_INC ${INC_SEARCH_LIST})

    set(_RET_DIRS "")

    foreach(HEAD_FILE ${_RET_INC})
        get_filename_component(directory_name ${HEAD_FILE} DIRECTORY)

        if(NOT ${directory_name} IN_LIST _RET_DIRS)
            list(APPEND _RET_DIRS ${directory_name})
        endif()
    endforeach(HEAD_FILE ${_RET_INC})

    set(${SRC_FILES} ${_RET_SRC} PARENT_SCOPE)
    set(${INC_FILES} ${_RET_INC} PARENT_SCOPE)
    set(${INC_DIRS} ${_RET_DIRS} PARENT_SCOPE)
endfunction(resolve_source_tree SRC_PATH SRC_FILES INC_FILES INC_DIRS)
