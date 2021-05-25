#!/bin/bash

# ------------------------------
# Source ROS and Enway workspace
# ------------------------------

# shellcheck disable=SC1091
source /opt/ros/melodic/setup.bash
source /opt/enway/ws/devel/setup.bash


# ---------
# Variables
# ---------

ENWAY_BUILD_SPACE=/opt/enway/ws/build
ENWAY_SOURCE_SPACE=/opt/enway/ws/src/cleansquare_ros


# ---------
# Functions
# ---------

log()
{
  printf "%s \n" "$1"
}

error()
{
  printf "\e[0;31m%s \e[0m \n" "ERROR: $1"
}

packageLog()
{
  printf "%-40s %s \n" "[$1]" "$2"
}

packageColoredLog()
{
  printf "\e[0;36m%-40s %s \e[0m \n" "[$1]" "$2"
}

packageWarn()
{
  printf "\e[0;33m%-40s %s \e[0m \n" "[$1]" "WARN: $2"
}

packageError()
{
  printf "\e[0;31m%-40s %s \e[0m \n" "[$1]" "ERROR: $2"
}

die()
{
  if [ $? != 0 ];
  then
    error "$1"
  fi
}

removeFolderIfNotInThisBranch()
{
  cd "$ENWAY_SOURCE_SPACE" || die "Could not cd into $ENWAY_SOURCE_SPACE - stopping script"

  FIND_RESULT=$(find . -name "$1" -not -path '*/\.*'  -print -quit)
  if [ "$FIND_RESULT" == "" ];
  then
    return 1
  fi

  cd "$FIND_RESULT" || die "Could not cd into $FIND_RESULT - stopping script"

  if [ "$(ls -1q | wc -l)" -eq 1 ];
  then
    if [ "$(ls)" == "compile_commands.json" ];
    then
      packageLog "$1" "Package is not present in this branch"
      packageLog "$1" "--> Removing package directory to keep source directory clean"
      cd ..
      rm -r ./"$1" || packageError "$1" "Failed to remove package directory"
      return 2
    fi
  fi
  return 0
}

checkIsExternalModule()
{
  roscd "$1"

  CURRENT_DIRECTORY="$(dirname "$(readlink -f "./package.xml" )" )"

  while [ "$(dirname "$CURRENT_DIRECTORY")" != "$ENWAY_SOURCE_SPACE" ];
  do
    if [ "$(dirname "$CURRENT_DIRECTORY")" == "$ENWAY_SOURCE_SPACE/external_modules" ];
    then
      return 1
    else
      CURRENT_DIRECTORY="$(dirname "$CURRENT_DIRECTORY")"
    fi
  done

  return 0
}

addSymlinkToCompileCommands()
{
  roscd "$1"

  if [[ ! -f "$ENWAY_BUILD_SPACE/$1/compile_commands.json" ]];
  then
    packageError "$1" "No compile_commands.json file found in $ENWAY_BUILD_SPACE/$1 (did you build this package?)"
    return 1
  fi

  if [[ ! -f "./compile_commands.json" ]];
  then
    packageLog "$1" "Adding symlink to compile commands"
    ln -s "$ENWAY_BUILD_SPACE/$1/compile_commands.json" ./ || packageError "$1" "Failed to add symlink to compile commands"
  fi
}

removeSymlinkToCompileCommandsAndCacheFolder()
{
  roscd "$1"

  if [[ -f "./compile_commands.json" ]];
  then
    packageLog "$1" "Removing symlink to compile commands"
    rm ./compile_commands.json || packageError "$1" "Failed to remove symlink to compile_commands"
  fi

  if [[ -d "./.cache" ]];
  then
    packageLog "$1" "Removing .cache directory"
    rm -r ./.cache || packageError "$1" "Failed to remove .cache directory"
  fi
}


# -----------
# Main script
# -----------

if [[ ! -d "${ENWAY_BUILD_SPACE}" ]];
then
  error "No build space found at $ENWAY_BUILD_SPACE"
  exit 1
fi
if [[ ! -d "${ENWAY_SOURCE_SPACE}" ]];
then
  error "No source space found at $ENWAY_SOURCE_SPACE"
  exit 1
fi

if [ "$1" == "" ];
then
  log "Adding symlinks to packages compile_commands.json for editor"
else
  log "Removing symlinks to packages compile_commands.json and removing .cache directories"
fi

for ENTRY in `ls $ENWAY_BUILD_SPACE`;
do

  if [[ ! -d "$ENWAY_BUILD_SPACE/$ENTRY" ]];
  then
    continue
  fi

  if [ "$ENTRY" == "catkin_tools_prebuild" ];
  then
    continue
  fi

  removeFolderIfNotInThisBranch "$ENTRY"
  RESULT=$?
  if [ $RESULT == 1 ];
  then
    packageWarn "$ENTRY" "Skipping - could not find package folder"
    continue
  fi
  if [ $RESULT == 2 ];
  then
    continue
  fi

  checkIsExternalModule "$ENTRY"
  if [ $? -eq 1 ];
  then
    packageColoredLog "$ENTRY" "Skipping - is external module"
    continue
  fi

  if [ "$1" == "" ];
  then
    addSymlinkToCompileCommands "$ENTRY"
  else
    removeSymlinkToCompileCommandsAndCacheFolder "$ENTRY"
  fi

done
