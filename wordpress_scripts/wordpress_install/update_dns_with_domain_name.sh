DOMAIN=${1}
DDI=""

## Function assumes domain given is a subdomain, and removes it.
function get_domain_id_with_domain {
  F_DOMAIN=`echo ${DOMAIN} | awk -F"." '{print $2"."$3}'`
  DOMAIN_ID=`curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://dns.api.rackspacecloud.com/v1.0/${DDI}/domains?name=${F_DOMAIN}" | python -mjson.tool | grep '"id":' | tr -d " " | tr -d "," | awk -F":" '{print $2}'`
}

function set_record_with_domain_id {
  curl -sX POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://dns.api.rackspacecloud.com/v1.0/${DDI}/domains/${DOMAIN_ID}/records" -d \
  "{
    \"records\" : [ {
      \"name\" : \"${DOMAIN}\",
      \"type\" : \"A\",
      \"data\" : \"\",
      \"ttl\" : 300 } ]
  }" &> /dev/null
}

get_domain_id_with_domain
set_record_with_domain_id
