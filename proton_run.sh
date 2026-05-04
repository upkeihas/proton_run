#!/bin/env bash
#
# Fast and hacky utility for running a Windows executable inside an existing Steam Proton compatibility environment.
# Useful for having to run simple update utilities, e.g. Punkbuster and .net stuff without having to combat Steam Ui to make it happen.
#

# TODO: give user a way to define these paths
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
_PROTON_EXE_PATH="$STEAM_COMPAT_CLIENT_INSTALL_PATH/steamapps/common/Proton - Experimental/proton"

_DRY_RUN=false

help () {
  echo "Usage:"
  echo "Run a windows executable inside Steam compatdata environment using Proton."
  echo ""
  echo "Application wine environment *must* exist. New Proton env creation support still in the works..."
  echo "See https://steamdb.info/apps/"
  echo ""
  echo "$0 -a <product steamid> -e <path to .exe file>"
  echo ""
  echo "Options:"
  echo ""
  echo "  -a|--appid: Product's Steam application ID. Used to locate compatibility environment path."
  echo ""
  echo "  -e|--executable: Path to executable file to be run in specified compatibility environment's context."
  echo ""
  echo "  -n|--not-really: Make sure we could, but do not actually run anything just yet."
  echo ""
  echo "  -p|--protonpath: Path to Proton executable file."
  echo ""
  echo "  -h|--help: Print this help and exit."
  echo ""
}


# No args
if ! [ $# -gt 0 ]; then
  help
  exit 2
fi


# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    -a|--appid)
      _STEAM_APPID=$2
      shift
      shift
    ;;
    -e|--executable)
      _WIN_EXE_PATH="$2"
      shift
      shift
    ;;
    -h|--help)
      help
      exit 0
    ;;
    -p|--protonpath)
      _PROTON_EXE_PATH="$2"
      shift
      shift
    ;;
    -n|--not-really)
      _DRY_RUN=true
      shift
    ;;
    *) # Unknown arg
      help
      exit 2
    ;;
  esac
done

# Exit on error; unset var equals error
set -eu

# Need proton to be installed
if ! test -f "$_PROTON_EXE_PATH"; then
  echo "Proton no found in path: $_PROTON_EXE_PATH"
  echo "Please define proton executable path manually!"
  exit 1
fi

export STEAM_COMPAT_DATA_PATH="$HOME/.steam/steam/steamapps/compatdata/$_STEAM_APPID"
export WINEPREFIX="$HOME/.steam/steam/steamapps/compatdata/$_STEAM_APPID/pfx"


# check env actually exists
if ! test -d "$STEAM_COMPAT_DATA_PATH"; then
  echo "Compatdata environment does not exist for Application id: $_STEAM_APPID"
  echo "Please make sure application id matches!"
  exit 1
fi


# run it
if [ $_DRY_RUN = true ]; then
  echo "STEAM_COMPAT_CLIENT_INSTALL_PATH = $STEAM_COMPAT_CLIENT_INSTALL_PATH"
  echo "STEAM_COMPAT_DATA_PATH = $STEAM_COMPAT_DATA_PATH"
  echo "_PROTON_EXE_PATH = $_PROTON_EXE_PATH"
  echo "WINEPREFIX = $WINEPREFIX"
  echo "Execute: $_PROTON_EXE_PATH run $_WIN_EXE_PATH"
  exit 2
else
  $("$_PROTON_EXE_PATH" run "$_WIN_EXE_PATH")
  exit $?
fi
