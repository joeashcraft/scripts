#!/bin/bash
## Requires "jq" application.

listNetworks() {
  OS_SERVICE_URL="https://dfw.servers.api.rackspacecloud.com/v2/${OS_PROJECT_ID}/os-networksv2"
  HEADER1="Content-Type: application/json"
  HEADER2="X-Auth-Token: ${OS_AUTH_TOKEN}"

  curl -sX GET -H "${HEADER1}" -H "${HEADER2}" ${OS_SERVICE_URL} | jq

}

listNetworks
