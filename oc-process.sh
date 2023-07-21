#!/bin/bash

i="all"

while getopts ":f:e:i::" flag; do
case $flag in
f) f=${OPTARG} ;;
e) e=${OPTARG} ;;
i) i=${OPTARG} ;;
esac
done

set -a

source ./$e

set +a

BRANCH=$(git symbolic-ref --short -q HEAD)

if [ "$BRANCH" != "main" ]; then

HOST=$HOST_DEV
FINBIF_ACCESS_TOKEN=$DEV_FINBIF_ACCESS_TOKEN
FINBIF_API=$DEV_FINBIF_API
GBIF_INSTALLATION=$DEV_GBIF_INSTALLATION
GBIF_PASS=$DEV_GBIF_PASS
GBIF_API=$DEV_GBIF_API

fi

if [ $i = "volume-var" ]; then

ITEM=".items[0]"

elif [ $i = "volume-archive" ]; then

ITEM=".items[1]"

elif [ $i = "image" ]; then

ITEM=".items[2]"

elif [ $i = "build" ]; then

ITEM=".items[3]"

elif [ $i = "deploy" ]; then

ITEM=".items[4]"

elif [ $i = "service" ]; then

ITEM=".items[5]"

elif [ $i = "route" ]; then

ITEM=".items[6]"

elif [ $i = "job" ]; then

ITEM=".items[7]"

else

  ITEM=""

fi

oc process -f $f \
-p BRANCH=$BRANCH \
-p HOST=$HOST \
-p FINBIF_ACCESS_TOKEN=$FINBIF_ACCESS_TOKEN \
-p FINBIF_API=$FINBIF_API \
-p GBIF_USER=$GBIF_USER \
-p GBIF_ORG=$GBIF_ORG \
-p GBIF_INSTALLATION=$GBIF_INSTALLATION \
-p GBIF_PASS=$GBIF_PASS \
-p GBIF_API=$GBIF_API \
| jq $ITEM
