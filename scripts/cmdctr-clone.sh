#!/bin/bash

function usage() {
  echo "Usage: $0 -h -b <branch-name> -d <depth>"
  echo "Options:"
  echo " -b|--branch                   The branch to be cloned, default is master"
  echo " -d|--depth                    The depth to be cloned, default is 1"
  echo " -h|--help                     Show this message"
  exit 1
}

[ "X$BRANCH" = "X" ] && BRANCH=master
[ "X$DEPTH" = "X" ] && DEPTH=1

while [[ $# > 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
    usage
    ;;

    -b|--branch)
    BRANCH="$2"
    shift # past argument
    ;;

    -d|--depth)
    DEPTH="$2"
    shift # past argument
    ;;

    *)
    ;;
  esac
  shift # past argument or value
done

REPOS="cmdctr-app ccng-ui cmdctr-ba cmdctr-cc cmdctr-cms cmdctr-fa cmdctr-im cmdctr-sv cmdctr-system cmdctr-user meteor-lib"
for s in $REPOS
do
  echo "git clone http://git/repos/sxa/$s --branch $BRANCH --depth=$DEPTH"
  git clone http://git/repos/sxa/$s --branch $BRANCH --depth=$DEPTH
done

