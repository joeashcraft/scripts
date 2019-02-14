#!/bin/bash
## Requires "jq" application.
OS_USER="${1}"
OS_API_KEY="${2}"

getToken() {

  OS_AUTH_URL="https://identity.api.rackspacecloud.com/v2.0/tokens"
  HEADER1="Content-Type: application/json"

  curl -sX POST -H "${HEADER1}" ${OS_AUTH_URL} \
  -d @- << EOF | jq -r '.access.token.id'
{
    "auth": {
        "RAX-KSKEY:apiKeyCredentials": {
            "username": "${OS_USER}",
            "apiKey": "${OS_API_KEY}"
        }
    }
}
EOF
}

getToken
