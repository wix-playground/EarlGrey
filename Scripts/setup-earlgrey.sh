#!/bin/bash
#
#  Copyright 2016 Google Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# A method to run a command and in case of any execution error
# echo a user provided error.
run_command() {
  ERROR="$1"
  shift
  "$@"
  if [[ $? != 0 ]]; then
     echo "$ERROR" >&2
     exit 1
  fi
}

# Turn on Debug Settings.
set -u

# Path of the script.
readonly EARLGREY_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Path of EarlGrey from the script.
readonly EARLGREY_DIR="${EARLGREY_SCRIPT_DIR}/.."

echo "Changing into EarlGrey Directory"
# Change Directory to the directory that contains EarlGrey.
pushd "${EARLGREY_SCRIPT_DIR}" >> /dev/null

echo "The EarlGrey Project and the Test Projects are ready to be run."
# Return back to the calling folder since the script ran successfully.
popd >> /dev/null
