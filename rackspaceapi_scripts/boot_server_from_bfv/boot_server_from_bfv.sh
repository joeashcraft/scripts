curl -skH "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://iad.servers.api.rackspacecloud.com/v2/${DDI}/os-volumes_boot" -d "@data.json"
