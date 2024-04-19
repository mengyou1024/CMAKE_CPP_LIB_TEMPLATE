cmake_minimum_required(VERSION 3.20)

project(cpp_lib_template)

set(CMAKE_CXX_STANDARD 20)

add_compile_options(
    "$<$<C_COMPILER_ID:MSVC>:/utf-8>"
    "$<$<CXX_COMPILER_ID:MSVC>:/utf-8>"
    "$<$<C_COMPILER_ID:MSVC>:/W4>"
    "$<$<CXX_COMPILER_ID:MSVC>:/W4>"
)

aux_source_directory(src CURRENT_SRC)
add_library(${PROJECT_NAME} ${CURRENT_SRC})
target_include_directories(${PROJECT_NAME} PUBLIC include)

if(BUILD_TEST)
    add_subdirectory(test)
endif()
