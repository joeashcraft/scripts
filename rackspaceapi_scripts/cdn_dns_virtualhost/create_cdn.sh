if [ -z "$1" ]
  then
    echo "No arguments supplied. Please provide a domain."
    exit
fi
DOMAIN=${1}
MARKER=`bash get_last_cdn_serviceid.sh`
sed "s/DOMAIN\.COM/${DOMAIN}/g" /etc/httpd/vhost.d/default.template > /etc/httpd/vhost.d/${DOMAIN}.conf
sed s/DOMAIN/${DOMAIN}/g data.template.json > data.json
curl -sX POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" https://global.cdn.api.rackspacecloud.com/v1.0/${DDI}/services -d @data.json
echo "CDN Service created.."
echo "Please wait for retrieval of CDN Service domain..."
sleep 30
CDNDOMAIN=`curl -sX GET -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" "https://global.cdn.api.rackspacecloud.com/v1.0/${DDI}/services?marker=${MARKER}" | python -mjson.tool | grep ${DOMAIN} | grep href | awk -F: '{print $2}' | tr -d \" | tr -d , | tr -d " "`
echo "CDN Service domain is: ${CDNDOMAIN}"
sed s/DOMAIN/${DOMAIN}/g domain.template.json | sed s/CDN/${CDNDOMAIN}/g > domain.json
echo "DNS entries created for root domain, origin, and www..."
curl -sX POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" https://dns.api.rackspacecloud.com/v1.0/${DDI}/domains -d @domain.json &> /dev/null
service httpd reload
echo "Virtual host created and Apache reloaded..."
chown -R zach:apache /var/www/vhosts
find /var/www/vhosts -type d -print0 | xargs -0 chmod 02775 && find /var/www/vhosts -type f -print0 | xargs -0 chmod 0664
echo "Permissions have been set.."
echo "Done"
