### Description ###############################
#  Provide the script with a root domain and 
#  it will automatically create the CDN service, 
#  DNS, and virtual host. This script is for creating
#  CDN services that follow the "www" method. Where
#  all traffic is redirected to "www.example.com"
#  from "example.com" and "origin.example.com" is
#  the origin.
###############################################

## Must have arguements.
if [ -z "$1" ]
  then
    echo "No arguments supplied. Please provide a domain; no subdomains."
    exit
fi
##

## Variables ##
# You should export your token with "export TOKEN=xxxxxxxxxxxx"
DOMAIN=${1}
DDI="893337"
EMAIL_ADDRESS="taylor.broesche@rackspace.com"  # Email address used when creating DNS entry.
IP_ADDRESS="192.168.3.1" # IP Address for root domain and "origin" subdomain.

## Functions ##
# This function assumes "default.template" is available for copy.
function create_vhost_from_template_and_domain {
  sed "s/DOMAIN\.COM/${DOMAIN}/g" /etc/httpd/vhost.d/default.template > /etc/httpd/vhost.d/${DOMAIN}.conf
}

function create_cdn_from_domain {
  sed s/DOMAIN/${DOMAIN}/g data.template.json > data.json
  curl -sX POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" https://global.cdn.api.rackspacecloud.com/v1.0/${DDI}/services -d @data.json
}

function get_cdn_href_from_domain {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/${DDI}/services" | python -mjson.tool | grep ${DOMAIN} | grep href | awk -F: '{print $2}' | tr -d \" | tr -d , | tr -d " "
}

function get_cdn_href_from_domain_with_marker {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/${DDI}/services?marker=${MARKER}" | python -mjson.tool | grep ${DOMAIN} | grep href | awk -F: '{print $2}' | tr -d \" | tr -d , | tr -d " "
}

function create_dns_from_cdn_and_domain {
  sed s/DOMAIN/${DOMAIN}/g domain.template.json | sed s/CDN/${CDNHREF}/g | sed s/EMAIL_ADDRESS/${EMAIL_ADDRESS}/g | sed s/IP_ADDRESS/${IP_ADDRESS}/g > domain.json
  curl -sX POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" https://dns.api.rackspacecloud.com/v1.0/${DDI}/domains -d @domain.json &> /dev/null
}

function get_number_of_cdn_services {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/${DDI}/services" | python -mjson.tool | grep "\"id\":" | wc -l  
}

function get_number_of_cdn_services_with_marker {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/${DDI}/services?marker=${MARKER}" | python -mjson.tool | grep "\"id\":" | wc -l
}

function get_last_id {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/${DDI}/services" | python -mjson.tool | grep "\"id\":" | awk -F":" '{print $2}' | tr -d " " | tr -d "\"" | tr -d "," | tail -1
}

function get_last_id_with_marker {
  curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/${DDI}/services?marker=${MARKER}" | python -mjson.tool | grep "\"id\":" | awk -F":" '{print $2}' | tr -d " " | tr -d "\"" | tr -d "," | tail -1
}

#function optional_post_commands {
#  service httpd reload
#  chown -R zach:apache /var/www/vhosts
#  find /var/www/vhosts -type d -print0 | xargs -0 chmod 02775 && find /var/www/vhosts -type f -print0 | xargs -0 chmod 0664
#}

## Main ##
#echo "Creating virtual host from template.."
#create_vhost_from_template_and_domain
echo "Checking number of current CDN services..."
NUMBERSERV=`get_number_of_cdn_services`
if [ ${NUMBERSERV} != 10 ] ; then
  echo "Current services: ${NUMBERSERV}, proceeding as normal."
  echo "Creating CDN for domain: ${DOMAIN}..."
  create_cdn_from_domain
  echo "Waiting 25 seconds for CDN HREF to become available..."
  sleep 25
  CDNHREF=`get_cdn_href_from_domain`
  echo "CDN HREF: ${CDNHREF}"
  echo "Creating DNS entries..."
  create_dns_from_cdn_and_domain
  echo "Done."
else
  echo "CDN services = ${NUMBERSERV}, applying different methodology.."
  echo "Creating CDN for domain: ${DOMAIN}..."
  create_cdn_from_domain
  echo "Waiting 25 seconds for CDN HREF to become available..."
  sleep 25
  CDNHREF=`get_cdn_href_from_domain`
  echo "CDN HREF: ${CDNHREF}"
  MARKER=`get_last_id`
  echo ${MARKER}
  while [ -z ${CDNHREF} ]; do
    echo "Couldn't find CDN HREF, looping through services.."
    CDNHREF=`get_cdn_href_from_domain_with_marker`
    echo ${CDNHREF}
    MARKER=`get_last_id_with_marker`
    echo ${MARKER}
  done
  echo "CDN HREF: ${CDNHREF}"
  create_dns_from_cdn_and_domain
  echo "Done."
fi
