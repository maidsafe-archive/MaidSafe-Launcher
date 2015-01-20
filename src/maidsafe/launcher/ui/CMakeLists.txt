#==================================================================================================#
#                                                                                                  #
#  Copyright 2015 MaidSafe.net limited                                                             #
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

set(Qt5Required OFF)
set(Qt5RequiredVersion 5.4.0)
set(Qt5RequiredLibs
      Qt5Concurrent
      Qt5Core
      Qt5Gui
      Qt5LinguistTools
      Qt5Network
      Qt5Qml
      Qt5Quick
      Qt5Script
      Qt5Svg
      Qt5Widgets)
include(../../../../../../cmake_modules/maidsafe_find_qt5.cmake)
if(NOT AllQt5_FOUND)
  message(STATUS "Didn't find all required modules of Qt5. Not building Launcher UI.")
  return()
endif()

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(launcher_ui)

include(../../../../../../cmake_modules/standard_setup.cmake)


#==================================================================================================#
# Set up all files as GLOBs.                                                                       #
#==================================================================================================#
set(UiMain ${PROJECT_SOURCE_DIR}/main.cc)
source_group("Auto Compiled\\Qt MOC Files" FILES "${CMAKE_CURRENT_BINARY_DIR}/safe_app_launcher_automoc.cpp")

ms_glob_dir(Helpers ${PROJECT_SOURCE_DIR}/helpers Helpers)

set(QtPchHeader ${PROJECT_SOURCE_DIR}/helpers/qt_push_headers.h)
if(NOT MSVC)
  list(REMOVE_ITEM HelpersSources ${PROJECT_SOURCE_DIR}/helpers/qt_push_headers.cc)
endif()

ms_glob_dir(Controllers ${PROJECT_SOURCE_DIR}/controllers Controllers)
ms_glob_dir(Models ${PROJECT_SOURCE_DIR}/models Models)

qt5_add_resources(ResourceFilesUiResourcesDir ${PROJECT_SOURCE_DIR}/main_resource.qrc)
source_group("Auto Compiled\\Resource Files" FILES ${ResourceFilesUiResourcesDir})

file(GLOB_RECURSE ViewsAllFiles ${PROJECT_SOURCE_DIR}/views/*.qml)
source_group("Views" FILES ${ViewsAllFiles})

file(GLOB_RECURSE CustomComponentsAllFiles ${PROJECT_SOURCE_DIR}/custom_components/*.qml)
source_group("Custom Components" FILES ${CustomComponentsAllFiles})

set(AllUiSourceFiles
      ${HelpersSources}
      ${ControllersSources}
      ${ModelsSources})
set(AllUiHeaderFiles
      ${HelpersHeaders}
      ${ControllersHeaders}
      ${ModelsHeaders})

#####    Set Application Icon    ####
if(MSVC)
  set(UiAppIconResource ${PROJECT_SOURCE_DIR}/app_icon.rc)
  source_group("Auto Compiled\\App Icon File" FILES ${UiAppIconResource})
endif()


#==================================================================================================#
# Define MaidSafe libraries and executables                                                        #
#==================================================================================================#
ms_add_executable(safe_app_launcher "Production" ${UiMain}
                                                 ${AllUiSourceFiles}
                                                 ${AllUiHeaderFiles}
                                                 ${ResourceFilesUiResourcesDir}
                                                 ${ViewsAllFiles}
                                                 ${CustomComponentsAllFiles}
                                                 ${UiAppIconResource})
target_include_directories(safe_app_launcher PRIVATE "../../../")
target_link_libraries(safe_app_launcher ${Qt5TargetLibs} maidsafe_common) # maidsafe_launcher
if(UNIX)
  set_source_files_properties(${AllUiSourceFiles} PROPERTIES COMPILE_FLAGS -Wno-float-equal)
endif()

if(MSVC)
  set_target_properties(safe_app_launcher PROPERTIES WIN32_EXECUTABLE TRUE)
endif()


#==================================================================================================#
# Set compiler and linker flags                                                                    #
#==================================================================================================#
include(../../../../../../cmake_modules/standard_flags.cmake)

target_compile_definitions(safe_app_launcher PRIVATE $<$<CONFIG:Release>:QT_NO_DEBUG_OUTPUT QT_NO_WARNING_OUTPUT>)

if(MSVC)
  string(REGEX REPLACE "/Zm[0-9]+ " "/Zm500 " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  set_source_files_properties(${AllUiSourceFiles} PROPERTIES
                              COMPILE_FLAGS "/Yu\"${QtPchHeader}\" /FI\"${QtPchHeader}\"")
  set_source_files_properties("${PROJECT_SOURCE_DIR}/helpers/qt_push_headers.cc" PROPERTIES
                              COMPILE_FLAGS "/Yc\"${QtPchHeader}\" /FI\"${QtPchHeader}\"")
endif()

message(STATUS "Found Qt5. Launcher UI enabled.")


#==================================================================================================#
# Generate Qt .pro file.                                                                           #
#==================================================================================================#
set(QtPROHelper ${CMAKE_BINARY_DIR}/safe_app_launcher_mock.pro)
file(WRITE ${QtPROHelper} "#This File is Auto-Generated. Do Not Edit Manually.")
file(APPEND ${QtPROHelper} "\nQT += qml quick widgets")
file(APPEND ${QtPROHelper} "\nTARGET = safe_app_launcher")

file(APPEND ${QtPROHelper} "\n\nSOURCES += ")
set(SourceFilesCollection ${UiMain} ${AllUiSourceFiles})
foreach(SourceFile ${SourceFilesCollection})
  file(APPEND ${QtPROHelper} "$$quote(${SourceFile}) ")
endforeach()

file(APPEND ${QtPROHelper} "\n\nHEADERS += ")
foreach(HeaderFile ${AllUiHeaderFiles})
  file(APPEND ${QtPROHelper} "$$quote(${HeaderFile}) ")
endforeach()

file(APPEND ${QtPROHelper} "\n\nRESOURCES += $$quote(${PROJECT_SOURCE_DIR}/main_resource.qrc)")

if(MSVC)
  if(POLICY CMP0026)
    cmake_policy(PUSH)
    cmake_policy(SET CMP0026 OLD)
  endif()
  ms_get_dependencies(maidsafe_launcher OptimizedDependencies DebugDependencies ON)
  get_target_property(ReleaseLocation maidsafe_launcher LOCATION_RELEASE)
  get_target_property(DebugLocation maidsafe_launcher LOCATION_DEBUG)
  if(POLICY CMP0026)
    cmake_policy(POP)
  endif()

  list(INSERT OptimizedDependencies 0 "\"${ReleaseLocation}\"")
  list(INSERT DebugDependencies 0 "\"${DebugLocation}\"")
  file(APPEND ${QtPROHelper} "\n\n*:CONFIG(release, debug|release): LIBS += ")
  foreach(OptimizedDependency ${OptimizedDependencies})
    file(APPEND ${QtPROHelper} "$$quote(${OptimizedDependency}) ")
  endforeach()
  file(APPEND ${QtPROHelper} "\nelse:*:CONFIG(debug, debug|release): LIBS += ")
  foreach(DebugDependency ${DebugDependencies})
    file(APPEND ${QtPROHelper} "$$quote(${DebugDependency}) ")
  endforeach()
endif()

file(APPEND ${QtPROHelper} "\n\nINCLUDEPATH += $$quote(${PROJECT_SOURCE_DIR})")

file(APPEND ${QtPROHelper} "\n\nOTHER_FILES += ")
foreach(ViewFile ${ViewsAllFiles} ${CustomComponentsAllFiles})
  file(APPEND ${QtPROHelper} "$$quote(${ViewFile}) ")
endforeach()
file(GLOB_RECURSE UiFilesResourceContentFiles ${PROJECT_SOURCE_DIR}/resources/*.*)
foreach(UiFilesResourceContentFile ${UiFilesResourceContentFiles})
  file(APPEND ${QtPROHelper} "$$quote(${UiFilesResourceContentFile}) ")
endforeach()
