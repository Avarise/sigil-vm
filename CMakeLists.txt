cmake_minimum_required(VERSION 3.10)
project(SigilVM VERSION 1.0.0 DESCRIPTION "SigilVM")

# Set the version of your project
set(Sigil_VERSION_MAJOR 1)
set(Sigil_VERSION_MINOR 0)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
endif()

# Compiler flags
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY 1)
set(CMAKE_USE_WIN32_THREADS_INIT 0)
set(CMAKE_USE_PTHREADS_INIT 1)
set(THREADS_PREFER_PTHREAD_FLAG ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DVK_PROTOTYPES")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DVK_PROTOTYPES")

# Libraries
find_package(Vulkan REQUIRED)
set(LIBRARIES "glfw;Vulkan::Vulkan")
option(GLFW_DOCUMENT_INTERNALS "Include internals in documentation" OFF)
option(GLFW_BUILD_EXAMPLES "Build the GLFW example programs" OFF)
option(GLFW_BUILD_TESTS "Build the GLFW test programs" OFF)
option(GLFW_BUILD_DOCS "Build the GLFW documentation" OFF)
option(GLFW_INSTALL "Generate installation target" OFF)

# Paths
set(VM_DIR ${CMAKE_SOURCE_DIR}/vm)
set(TEST_DIR ${CMAKE_SOURCE_DIR}/tests)
set(APPS_DIR ${CMAKE_SOURCE_DIR}/apps)
set(GLFW_DIR ${CMAKE_SOURCE_DIR}/extern/glfw)
set(IMGUI_DIR ${CMAKE_SOURCE_DIR}/extern/imgui)

# VM library helpers
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix "\${prefix}")
set(libdir "\${exec_prefix}/lib")
set(includedir "\${prefix}/include")

# File globs, to be replaced by manual lists based on funcitonality
file(GLOB VM_SOURCE ${VM_DIR}/*.cpp)
file(GLOB VM_HEADERS ${VM_DIR}/*.h)
file(GLOB SOURCE_GLFW ${GLFW_DIR}/*.cpp)
file(GLOB SOURCE_IMGUI ${IMGUI_DIR}/*.cpp) 

add_subdirectory(${GLFW_DIR} binary_dir EXCLUDE_FROM_ALL)
include_directories(${GLFW_DIR}/include)
include_directories(${GLFW_DIR}/deps)
include_directories(${VM_DIR})
include_directories(${IMGUI_DIR} ${IMGUI_DIR}/backends ..)

# Build target: sigil library
add_library(sigil SHARED ${VM_SOURCE})
set_target_properties(sigil PROPERTIES
    VERSION ${Sigil_VERSION_MAJOR}.${Sigil_VERSION_MINOR}
    SOVERSION ${Sigil_VERSION_MAJOR}
    PUBLIC_HEADER "${VM_HEADERS}"
)

# Installation directives
install(TARGETS sigil LIBRARY DESTINATION lib PUBLIC_HEADER DESTINATION include/sigil)
configure_file(sigil.pc.in sigil.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/sigil.pc DESTINATION lib/pkgconfig)

# Build target: sigil-tools
add_executable(sigil-tools ${APPS_DIR}/tools.cpp ${VM_SOURCE} ${SOURCE_IMGUI} ${SOURCE_GLFW} ${SOURCE_IMGUI_BACKEND})
target_link_libraries(sigil-tools ${LIBRARIES})
target_compile_definitions(sigil-tools PUBLIC)

# Build target: sigil-editor
add_executable(sigil-editor ${APPS_DIR}/editor.cpp ${VM_SOURCE} ${SOURCE_IMGUI} ${SOURCE_GLFW} ${SOURCE_IMGUI_BACKEND})
target_link_libraries(sigil-editor ${LIBRARIES})
target_compile_definitions(sigil-editor PUBLIC -DImTextureID=ImU64 -DSIGIL_USE_GUI)

# Build target: testing suites
enable_testing()
add_executable(sigil-initialization-suite ${TEST_DIR}/initialization-suite.cpp ${VM_SOURCE} ${SOURCE_IMGUI} ${SOURCE_GLFW} ${SOURCE_IMGUI_BACKEND})
add_executable(sigil-networking-suite ${TEST_DIR}/networking-suite.cpp ${VM_SOURCE} ${SOURCE_IMGUI} ${SOURCE_GLFW} ${SOURCE_IMGUI_BACKEND})
add_executable(sigil-windowing-suite ${TEST_DIR}/parser-suite.cpp ${VM_SOURCE} ${SOURCE_IMGUI} ${SOURCE_GLFW} ${SOURCE_IMGUI_BACKEND})
add_executable(sigil-parser-suite ${TEST_DIR}/windowing-suite.cpp ${VM_SOURCE} ${SOURCE_IMGUI} ${SOURCE_GLFW} ${SOURCE_IMGUI_BACKEND})
target_link_libraries(sigil-initialization-suite ${LIBRARIES} gtest gtest_main)
target_link_libraries(sigil-networking-suite ${LIBRARIES} gtest gtest_main)
target_link_libraries(sigil-windowing-suite ${LIBRARIES} gtest gtest_main)
target_link_libraries(sigil-parser-suite ${LIBRARIES} gtest gtest_main)
target_compile_definitions(sigil-initialization-suite PUBLIC -DImTextureID=ImU64 -DSIGIL_USE_GUI)
target_compile_definitions(sigil-networking-suite PUBLIC -DImTextureID=ImU64 -DSIGIL_USE_GUI)
target_compile_definitions(sigil-windowing-suite PUBLIC -DImTextureID=ImU64 -DSIGIL_USE_GUI)
target_compile_definitions(sigil-parser-suite PUBLIC -DImTextureID=ImU64 -DSIGIL_USE_GUI)

add_test(NAME InitializationTestSuite COMMAND ${CMAKE_BINARY_DIR}/sigil-initialization-suite)
add_test(NAME NetworkingTestSuite COMMAND ${CMAKE_BINARY_DIR}/sigil-networking-suite)
add_test(NAME WindowingTestSuite COMMAND ${CMAKE_BINARY_DIR}/sigil-windowing-suite)
add_test(NAME ParserTestSuite COMMAND ${CMAKE_BINARY_DIR}/sigil-parser-suite)