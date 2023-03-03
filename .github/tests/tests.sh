#!/bin/bash

old_ifs="$IFS"
IFS=";"
has_error=0

function print() {
  echo -e "$3 The configuration '$1' is $2"
}

while read property expected message
do
  if [[ $(echo $1 | jq $property) =~ $expected ]]
  then
    print $message OK '\033[0;32m'
  else
    print $message WRONG '\033[0;31m'
    has_error=1
  fi
done < $2

IFS=$old_ifs
exit $has_error
