#==================================================================================================#
#                                                                                                  #
#  Copyright 2014 MaidSafe.net limited                                                             #
#                                                                                                  #
#  This MaidSafe Software is licensed to you under (1) the MaidSafe.net Commercial License,        #
#  version 1.0 or later, or (2) The General Public License (GPL), version 3, depending on which    #
#  licence you accepted on initial access to the Software (the "Licences").                        #
#                                                                                                  #
#  By contributing code to the MaidSafe Software, or to this project generally, you agree to be    #
#  bound by the terms of the MaidSafe Contributor Agreement, version 1.0, found in the root        #
#  directory of this project at LICENSE, COPYING and CONTRIBUTOR respectively and also available   #
#  at: http://www.maidsafe.net/licenses                                                            #
#                                                                                                  #
#  Unless required by applicable law or agreed to in writing, the MaidSafe Software distributed    #
#  under the GPL Licence is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF   #
#  ANY KIND, either express or implied.                                                            #
#                                                                                                  #
#  See the Licences for the specific language governing permissions and limitations relating to    #
#  use of the MaidSafe Software.                                                                   #
#                                                                                                  #
#==================================================================================================#


set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../../cmake_modules/standard_setup.cmake")
  cmake_minimum_required(VERSION 2.8)  # To suppress warning cluttering error message
  set(Msg "\nThis project can currently only be build as part of the MaidSafe super-project.  For")
  set(Msg "${Msg} full details, see https://github.com/maidsafe/MaidSafe/wiki/Build-Instructions\n")
  message(FATAL_ERROR "${Msg}")
endif()

project(launcher)

include(../../cmake_modules/standard_setup.cmake)


#==================================================================================================#
# Set up all files as GLOBs                                                                        #
#==================================================================================================#
set(LauncherSourcesDir ${PROJECT_SOURCE_DIR}/src/maidsafe/launcher)
ms_glob_dir(Launcher ${LauncherSourcesDir} Launcher)
list(REMOVE_ITEM LauncherAllFiles "${LauncherSourcesDir}/launcher_main.cc")

ms_glob_dir(LauncherTests ${LauncherSourcesDir}/tests Tests)
list(REMOVE_ITEM LauncherTestsAllFiles "${LauncherSourcesDir}/tests/dummy_app.cc")


#==================================================================================================#
# Define MaidSafe libraries and executables                                                        #
#==================================================================================================#
ms_add_static_library(maidsafe_launcher ${LauncherAllFiles})
target_include_directories(maidsafe_launcher PUBLIC ${PROJECT_SOURCE_DIR}/include PRIVATE ${PROJECT_SOURCE_DIR}/src)
set(ApplicationName SafeLauncher)
target_compile_definitions(maidsafe_launcher PUBLIC COMPANY_NAME=MaidSafe APPLICATION_NAME=${ApplicationName})
# TODO - Once NFS has taken over Drive's duties, swap maidsafe_drive for maidsafe_nfs
target_link_libraries(maidsafe_launcher maidsafe_api maidsafe_passport) # maidsafe_drive)

if(INCLUDE_TESTS)
  target_compile_definitions(maidsafe_launcher PUBLIC USE_FAKE_STORE)
  target_link_libraries(maidsafe_launcher maidsafe_test)

  set(dummy_launcherName ${ApplicationName})
  ms_add_executable(dummy_launcher "Tests/Launcher" "${LauncherSourcesDir}/launcher_main.cc")
  target_include_directories(dummy_launcher PRIVATE ${PROJECT_SOURCE_DIR}/src)
  target_link_libraries(dummy_launcher maidsafe_launcher)

  set(test_launcherName ${ApplicationName})
  ms_add_executable(test_launcher "Tests/Launcher" ${LauncherTestsAllFiles})
  target_include_directories(test_launcher PRIVATE ${PROJECT_SOURCE_DIR}/src)
  target_link_libraries(test_launcher maidsafe_launcher)

  set(dummy_appName ${ApplicationName})
  ms_add_executable(dummy_app "Tests/Launcher" "${LauncherSourcesDir}/tests/dummy_app.cc")
  target_link_libraries(dummy_app maidsafe_launcher)

  add_dependencies(test_launcher dummy_app)

  set(test_launcher_multiple_definitionsName ${ApplicationName})
endif()

ms_rename_outdated_built_exes()


#==================================================================================================#
# Set compiler and linker flags                                                                    #
#==================================================================================================#
include(standard_flags)


#==================================================================================================#
# Tests                                                                                            #
#==================================================================================================#
if(INCLUDE_TESTS)
  ms_add_default_tests()
  ms_add_gtests(test_launcher)
  ms_test_summary_output()
endif()


#==================================================================================================#
# Launcher UI                                                                                      #
#==================================================================================================#
add_subdirectory(${LauncherSourcesDir}/ui)
