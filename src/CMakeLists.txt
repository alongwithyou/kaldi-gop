cmake_minimum_required (VERSION 2.6)
project (kaldi-gop)

# BLAS
find_package(BLAS REQUIRED)
if(NOT BLAS_FOUND)
  message(FATAL_ERROR "Can't find BLAS. On Ubunbu, you may want to "
                "install it by:\n  sudo apt-get install libatlas-dev")
endif()

# Build Kaldi
SET(KALDI_ROOT "${CMAKE_SOURCE_DIR}/kaldi-5.1")
SET(BUILD_JOBS 8)
SET(ERR_CODE -1)
if(NOT EXISTS ${KALDI_ROOT})
  execute_process(COMMAND wget https://github.com/kaldi-asr/kaldi/archive/5.1.zip
                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  execute_process(COMMAND unzip 5.1.zip -d ${CMAKE_SOURCE_DIR}
                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  execute_process(COMMAND make -j ${BUILD_JOBS} WORKING_DIRECTORY ${KALDI_ROOT}/tools)
  execute_process(COMMAND ./configure WORKING_DIRECTORY ${KALDI_ROOT}/src)
  execute_process(COMMAND make depend -j ${BUILD_JOBS} WORKING_DIRECTORY ${KALDI_ROOT}/src)
  execute_process(COMMAND make -j ${BUILD_JOBS} WORKING_DIRECTORY ${KALDI_ROOT}/src)
endif()

# Settings
add_compile_options(-std=c++11)
add_definitions(-DHAVE_ATLAS)
add_definitions(-Wno-deprecated-declarations)
include_directories("${KALDI_ROOT}/src")
include_directories("${KALDI_ROOT}/tools/openfst/include")
include_directories("${KALDI_ROOT}/tools/ATLAS/include")

# gop
include_directories(".")
file(GLOB GOP "gop/*.cc")
add_library(gop ${GOP})
target_link_libraries(gop ${KALDI_ROOT}/src/decoder/kaldi-decoder.a)
target_link_libraries(gop ${KALDI_ROOT}/src/fstext/kaldi-fstext.a)
target_link_libraries(gop ${KALDI_ROOT}/src/hmm/kaldi-hmm.a)
target_link_libraries(gop ${KALDI_ROOT}/src/gmm/kaldi-gmm.a)
target_link_libraries(gop ${KALDI_ROOT}/src/tree/kaldi-tree.a)
target_link_libraries(gop ${KALDI_ROOT}/src/util/kaldi-util.a)
target_link_libraries(gop ${KALDI_ROOT}/src/matrix/kaldi-matrix.a)
target_link_libraries(gop ${KALDI_ROOT}/src/base/kaldi-base.a)
target_link_libraries(gop ${KALDI_ROOT}/tools/openfst/lib/libfst.a)
target_link_libraries(gop dl.so)
target_link_libraries(gop /usr/lib/libatlas.so.3)
target_link_libraries(gop /usr/lib/libf77blas.so.3)
target_link_libraries(gop /usr/lib/libcblas.so.3)
target_link_libraries(gop /usr/lib/liblapack_atlas.so.3)

# compute-gmm-gop
add_executable(compute-gmm-gop gopbin/compute-gmm-gop.cc)
target_link_libraries(compute-gmm-gop gop)
find_package(Threads)
target_link_libraries(compute-gmm-gop ${CMAKE_THREAD_LIBS_INIT})
