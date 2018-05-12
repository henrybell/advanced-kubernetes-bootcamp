#!/usr/bin/env bash

if [ "X$SERVICE_ACCOUNT" != "X" ]; then
    /fileark --projectid ${PROJECT_ID} --bucket ${BUCKET} --serviceaccount ${SERVICE_ACCOUNT}
else
    /fileark --projectid ${PROJECT_ID} --bucket ${BUCKET}
fi

exit 0
