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

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR} _TEST_SRC)

add_executable(unit_tests ${_TEST_SRC})
target_link_libraries(unit_tests PRIVATE gtest_main ${PROJECT_NAME})
include(GoogleTest)
gtest_discover_tests(unit_tests PROPERTIES LABELS "File" DISCOVERY_TIMEOUT 240)
