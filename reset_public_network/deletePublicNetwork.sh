#!/bin/bash

deletePublicNet() {
  OS_SERVICE_URL="https://dfw.servers.api.rackspacecloud.com/v2/${OS_PROJECT_ID}/servers/${OS_SERVER_ID}/os-virtual-interfacesv2/${OS_INTERFACE_ID}"
  HEADER1="Content-Type: application/json"
  HEADER2="X-Auth-Token: ${OS_AUTH_TOKEN}"

  curl -vX DELETE -H "${HEADER1}" -H "${HEADER2}" ${OS_SERVICE_URL}
}

deletePublicNet
