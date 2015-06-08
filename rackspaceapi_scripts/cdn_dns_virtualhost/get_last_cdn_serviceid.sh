#DOMAIN=${1}
function get_first_id {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/959019/services" | python -mjson.tool | grep "\"id\":" | awk -F":" '{print $2}' | tr -d " " | tr -d "\"" | tr -d "," | head -1
}

function get_last_id_with_marker {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/959019/services?marker=${1}" | python -mjson.tool | grep "\"id\":" | awk -F":" '{print $2}' | tr -d " " | tr -d "\"" | tr -d "," | tail -1
}

function get_count {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/959019/services" | python -mjson.tool | grep "\"id\":" | wc -l
}

function get_count_with_marker {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/959019/services?marker=${1}" | python -mjson.tool | grep "\"id\":" | wc -l
}

function get_last_id {
  COUNT=`get_count`
  MARKER=`get_first_id`
  while [ ${COUNT} == 10 ]; do
    MARKER=`get_last_id_with_marker ${MARKER}`
    COUNT=`get_count_with_marker ${MARKER}`
  done
  echo ${MARKER}
}

get_last_id
