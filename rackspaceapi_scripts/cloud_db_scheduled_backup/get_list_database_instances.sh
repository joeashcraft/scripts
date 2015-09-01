#!/bin/env bash
## Export token before running this script.
## This script requires the DDI as the first arguement.
DDI=${1}
curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" https://iad.databases.api.rackspacecloud.com/v1.0/${DDI}/instances | python -mjson.tool 
