cmake_minimum_required(VERSION 3.4.1)

add_library( native_sim
             
             # Sets the library as a shared library.
             SHARED

             # Provides a path to your source file(s)
             ../ios/Classes/native_sim.cpp )

target_include_directories(native_sim PRIVATE $ENV{BOOST_DIR})