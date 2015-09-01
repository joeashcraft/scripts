#!/bin/env bash
## Export token before running this script.
## This script requires the DDI as the first arguement and the database instance ID as the second.
DDI=${1}
INSTANCE_ID=${2}
PAYLOAD=`sed s/INSTANCE_ID/${INSTANCE_ID}/g data.json.template > data.json`
curl -sX POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" https://iad.databases.api.rackspacecloud.com/v1.0/${DDI}/schedules -d @data.json | python -m json.tool
