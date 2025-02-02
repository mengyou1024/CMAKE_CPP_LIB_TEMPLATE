include(FetchContent)
enable_testing()
FetchContent_Declare(gtest
    QUIET
    URL https://codeload.github.com/google/googletest/tar.gz/refs/tags/v1.14.0
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(gtest)

resolve_source_tree("../src" SRC_FILES INC_FILES INC_DIRS)
resolve_source_tree("." TEST_SRC_FILES TEST_INC_FILES TEST_INC_DIRS)

if(TARGET unit_tests)
    target_sources(
        unit_tests
        PRIVATE
        ${SRC_FILES} ${INC_FILES}
        ${TEST_SRC_FILES} ${TEST_INC_FILES}
    )
else(TARGET unit_tests)
    add_executable(
        unit_tests
        ${SRC_FILES} ${INC_FILES}
        ${TEST_SRC_FILES} ${TEST_INC_FILES}
    )
    target_link_libraries(unit_tests PRIVATE gtest_main)
    include(GoogleTest)
    gtest_discover_tests(unit_tests)
endif(TARGET unit_tests)

target_include_directories(
    unit_tests
    PRIVATE
    "../include"
    ${INC_DIRS}
    ${TEST_INC_DIRS}
)

target_link_libraries(
    unit_tests
    PRIVATE
    cpp_lib_template
)
