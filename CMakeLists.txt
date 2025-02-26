cmake_minimum_required(VERSION 3.20)

project(cpp_lib_template)

include(cmake/Utils.cmake)

set(CMAKE_CXX_STANDARD 23)

resolve_source_tree("src" SRC_FILES INC_FILES INC_DIRS)

add_library(${PROJECT_NAME} STATIC ${SRC_FILES} ${INC_FILES})

target_include_directories(${PROJECT_NAME} PUBLIC include)
target_include_directories(${PROJECT_NAME} PRIVATE ${INC_DIRS})

target_compile_options(
    ${PROJECT_NAME}
    PUBLIC
    "$<$<C_COMPILER_ID:MSVC>:/utf-8>"
    "$<$<CXX_COMPILER_ID:MSVC>:/utf-8>"
    "$<$<C_COMPILER_ID:MSVC>:/W4>"
    "$<$<CXX_COMPILER_ID:MSVC>:/W4>"
)

if(BUILD_TESTING)
    include(CTest)
    add_subdirectory(test)
endif()

add_clang_tidy_pre_build(${PROJECT_NAME})
