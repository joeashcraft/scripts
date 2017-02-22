OS_USER=""
OS_API_KEY=""
OS_AUTH_URL="https://identity.api.rackspacecloud.com/v2.0/tokens"
HEADERS="-H 'Content-Type': 'application/json'"
curl -X POST -H ${HEADERS} ${OS_AUTH_URL}
