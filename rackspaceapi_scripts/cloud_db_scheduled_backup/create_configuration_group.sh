#!/bin/bash
DDI=${1}
REGION=${2}

curl -v -X POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" https://${REGION}.databases.api.rackspacecloud.com/v1.0/${DDI}/configurations -d @create_configuration_group.data.json
