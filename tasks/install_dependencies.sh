#!/bin/sh

if ! command -v node -v &> /dev/null
then
  echo "node not found! install node -> https://nodejs.org/en/"
  exit 1
fi

# if ! command -v yarn -v &> /dev/null
# then
#   echo "yarn not found! install yarn -> https://yarnpkg.com/getting-started/install"
#   exit 1
# fi

# yarn set version berry
#
# echo "yarn@2.4.0 needs a workaround to support node >= 15.4.x"
# echo "https://github.com/yarnpkg/berry/issues/2232#issuecomment-752052924"
# yarn set version from sources --branch 2262
#
# yarn install

# # updating yarncr file to play nice with rescript
# re='.*(:).+'
# # find assignment type argument from argument tab
# for arg; do
#   if [[ "$arg" =~ $re ]] && [ ${BASH_REMATCH[1]} == ':' ]; then
#   echo "appending"
#   echo $arg | tee -a '.yarnrc.yml'
#   echo "to '.yarnrc.yml'"
#   echo "attention: check if '$arg' exists, once!"
#   fi
# done

npm install npm@7 --save-dev

npm install
