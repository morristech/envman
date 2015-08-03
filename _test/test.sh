#!/bin/bash

set -e

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${THIS_SCRIPT_DIR}/.."

set -v

mkdir -p "$HOME/.envman/test"

#****************************#
# Init in default envman dir #
#****************************#
envman init -c
envman print
echo "bitrise from stdin" | envman add --key BITRISE_FROM_STDIN
envman add --key BITRISE --value "test bitrise value"
envman run bash "$THIS_SCRIPT_DIR/runCmd_test.sh"
set +e
envman run bash "$THIS_SCRIPT_DIR/runCmd_test_fail.sh"
fail_res="$?"
set +v
if [ "$fail_res" -ne "23" ] ; then
    echo "Not the expected exit code: $fail_res"
    exit 1
fi
set -e
set -v
envman print


#************************#
# Init in specified path #
#************************#
envman --path "$HOME/.envman/test/.envstore.yml" init -c
envman --path "$HOME/.envman/test/.envstore.yml" print
echo "bitrise from stdin" | envman --path "$HOME/.envman/test/.envstore.yml" add --key BITRISE_FROM_STDIN --no-expand
envman --path "$HOME/.envman/test/.envstore.yml" add --key BITRISE --value "test bitrise value" --no-expand
envman --path "$HOME/.envman/test/.envstore.yml" run bash "$THIS_SCRIPT_DIR/runCmd_test.sh"
envman --path "$HOME/.envman/test/.envstore.yml" print


#******************************************************#
# Init in current path, if .envstore.yml exist (exist) #
#******************************************************#
cd "$HOME/.envman/test/"
envman init -c
envman print
echo "bitrise from stdin" | envman add --key BITRISE_FROM_STDIN --no-expand
envman add --key BITRISE --value "test bitrise value"
envman run bash "$THIS_SCRIPT_DIR/runCmd_test.sh"
envman print


#**********************************************************#
# Init in current path, if .envstore.yml exist (not exist) #
#**********************************************************#
set +e
rm -rf "$HOME/.envman/test-emtpy"
set -e
mkdir -p "$HOME/.envman/test-emtpy"

cd "$HOME/.envman/test-emtpy"
envman init -c
envman print
echo "bitrise from stdin" | envman add --key BITRISE_FROM_STDIN --no-expand
envman add --key BITRISE --value "test bitrise value"
envman run bash "$THIS_SCRIPT_DIR/runCmd_test.sh"
envman print

#***********************#
# Add env from temp dir #
#***********************#
echo 'This is a test' > $THIS_SCRIPT_DIR/test.txt

envman add --key BITRISE_FROM_FILE --valuefile $THIS_SCRIPT_DIR/test.txt

rm -rf $THIS_SCRIPT_DIR/test.txt
