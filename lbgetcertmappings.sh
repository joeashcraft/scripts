region=$1
token=$2
account=$3
loadbalancerid=$4
curl -skH "X-Auth-Token: ${token}" https://${region}.loadbalancers.api.rackspacecloud.com/v1.0/${account}/loadbalancers/${loadbalancerid}/ssltermination/certificatemappings
