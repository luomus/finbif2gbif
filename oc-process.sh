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
STORAGE=$STORAGE_DEV
FINBIF_ACCESS_TOKEN=$FINBIF_ACCESS_TOKEN_DEV
FINBIF_API=$FINBIF_API_DEV
GBIF_INSTALLATION=$GBIF_INSTALLATION_DEV
GBIF_PASS=$GBIF_PASS_DEV
GBIF_API=$GBIF_API_DEV
JOB_SECRET=$JOB_SECRET_DEV

fi

if [ $i = "volume" ]; then

ITEM=".items[0]"

elif [ $i = "config" ]; then

ITEM=".items[1]"

elif [ $i = "deploy" ]; then

ITEM=".items[2]"

elif [ $i = "service" ]; then

ITEM=".items[3]"

elif [ $i = "route" ]; then

ITEM=".items[4]"

elif [ $i = "job" ]; then

ITEM=".items[5]"

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
-p STORAGE=$STORAGE \
-p JOB_SECRET=$JOB_SECRET \
-p SMTP_SERVER=$SMTP_SERVER \
-p SMTP_PORT=$SMTP_PORT \
-p ERROR_EMAIL_TO=$ERROR_EMAIL_TO \
-p ERROR_EMAIL_FROM=$ERROR_EMAIL_FROM \
| jq $ITEM
