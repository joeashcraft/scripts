#!/bin/bash

listInterfaces() {
  OS_SERVICE_URL="https://dfw.servers.api.rackspacecloud.com/v2/${OS_PROJECT_ID}/servers/11b40259-7469-454a-9eb3-a588f4bdf4ff/os-virtual-interfacesv2"
  HEADER1="Content-Type: application/json"
  HEADER2="X-Auth-Token: ${OS_AUTH_TOKEN}"

  curl -sX GET -H "${HEADER1}" -H "${HEADER2}" ${OS_SERVICE_URL} | jq
}

listInterfaces
