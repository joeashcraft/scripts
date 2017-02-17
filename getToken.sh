#!/bin/bash
## Requires "jq" application.
OS_USER=""
OS_API_KEY=""

getToken() {

  OS_AUTH_URL="https://identity.api.rackspacecloud.com/v2.0/tokens"
  HEADER1="Content-Type: application/json"

  curl -sX POST -H "${HEADER1}" ${OS_AUTH_URL} \
  -d @- << EOF | jq '.access.token.id'
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

OS_AUTH_TOKEN=$(getToken)
#echo $OS_AUTH_TOKEN
## Now do what you need with $OS_AUTH_TOKEN
