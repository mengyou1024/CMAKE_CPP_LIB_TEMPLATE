cmake_minimum_required(VERSION 3.20)

project(cpp_lib_template)

set(CMAKE_CXX_STANDARD 20)

file(GLOB_RECURSE ${PROJECT_NAME}_SRC "src/*.cpp" "src/*.c" "src/*.cc" "src/*.cxx")
file(GLOB_RECURSE ${PROJECT_NAME}_INC "src/*.h" "src/*.hpp")

set(${PROJECT_NAME}_INCLUDE_DIRS "")

foreach(HEAD_FILE ${${PROJECT_NAME}_INC})
    get_filename_component(directory_name ${HEAD_FILE} DIRECTORY)
    list(FIND ${PROJECT_NAME}_INCLUDE_DIRS ${directory_name} index)

    if(${index} EQUAL -1)
        list(APPEND ${PROJECT_NAME}_INCLUDE_DIRS ${directory_name})
    endif()
endforeach(HEAD_FILE ${PROJECT_NAME})

add_library(
    ${PROJECT_NAME}
    ${${PROJECT_NAME}_SRC}
    ${${PROJECT_NAME}_INC}
)
target_include_directories(${PROJECT_NAME} PUBLIC include)
target_include_directories(${PROJECT_NAME} PRIVATE ${${PROJECT_NAME}_INCLUDE_DIRS})

target_compile_options(
    ${PROJECT_NAME}
    PUBLIC
    "$<$<C_COMPILER_ID:MSVC>:/utf-8>"
    "$<$<CXX_COMPILER_ID:MSVC>:/utf-8>"
    "$<$<C_COMPILER_ID:MSVC>:/W4>"
    "$<$<CXX_COMPILER_ID:MSVC>:/W4>"
)

if(BUILD_TEST)
    add_subdirectory(test)
endif()

function(add_clang_tidy_pre_build target_name)
    # 查找clang-tidy可执行文件
    find_program(CLANG_TIDY_EXECUTABLE clang-tidy)

    if(CLANG_TIDY_EXECUTABLE)
        message(STATUS "Found clang-tidy: ${CLANG_TIDY_EXECUTABLE}")
    else()
        message(WARNING "clang-tidy not found, use: `choco install llvm` to install clang-tidy")
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

add_clang_tidy_pre_build(${PROJECT_NAME})
