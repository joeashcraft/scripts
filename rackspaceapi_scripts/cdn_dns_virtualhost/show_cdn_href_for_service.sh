DOMAIN=${1}
echo `curl -s -X GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" https://global.cdn.api.rackspacecloud.com/v1.0/959019/services | python -mjson.tool | grep ${DOMAIN} | grep href | awk -F: '{print $2}' | tr -d \" | tr -d , | tr -d " "`
