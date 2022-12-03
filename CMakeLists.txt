cmake_minimum_required(VERSION 3.20)

project(cuda_study
    VERSION   0.1
    LANGUAGES CXX CUDA
)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

foreach(lang CXX CUDA)
    set(CMAKE_${lang}_STANDARD          17)
    set(CMAKE_${lang}_STANDARD_REQUIRED ON)
    set(CMAKE_${lang}_EXTENSIONS        OFF)
endforeach()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

add_executable(test t1.cu)
set_property(TARGET test PROPERTY CUDA_ARCHITECTURES 86)

add_executable(matrixsum src/sumMatrix.cu)
set_property(TARGET matrixsum PROPERTY CUDA_ARCHITECTURES 86)