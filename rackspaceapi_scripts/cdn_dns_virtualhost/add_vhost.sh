## Usage: add_vhost.sh example.com
## Does not support subdomains at the moment.
DOMAIN=${1}
sed "s/DOMAIN\.COM/${DOMAIN}/g" /etc/httpd/vhost.d/default.template > /etc/httpd/vhost.d/${DOMAIN}.conf
