#!/bin/bash
DOMAIN=${1}
CONFIG_PATH=''
PARENT_ROOT='/var/www/vhosts'
APACHE_NAME=''
SSL_PATH=''

if [ ! -d ${PARENT_ROOT} ]; then 
    echo -e "Notice: No ${PARENT_ROOT} folder found.";
fi

if [ -f /etc/redhat-release ]; then
    CONFIG_PATH="/etc/httpd/vhost.d";
    APACHE_NAME="httpd";
    SSL_PATH="/etc/pki/tls";
    #echo "Red Hat Environment Detected...";
    if [ ! -d /etc/httpd/vhost.d ]; then 
        echo -e "Fatal: Cannot find ${CONFIG_PATH}, exiting.";
        exit;
    fi
fi
if [ -f /etc/debian_version ]; then
    CONFIG_PATH="/etc/apache2/sites-available";
    APACHE_NAME="apache2";
    SSL_PATH="/etc/ssl";
    #echo "Debian Environment Detected...";
    if [ ! -d /etc/apache2/sites-available ]; then 
        echo "Fatal: Cannot find ${CONFIG_PATH}, exiting.";
        exit;
    fi
fi
if [ -z ${CONFIG_PATH} ]; then
    echo -e "Fatal: Could not determine configuration path for Apache, exiting."; exit;
fi

cat << EOF > ${CONFIG_PATH}/${DOMAIN}.conf
<VirtualHost *:80>
        ServerName ${DOMAIN}
        ServerAlias www.${DOMAIN}
        #### This is where you put your files for that domain: /var/www/vhosts/${DOMAIN}
        DocumentRoot /var/www/vhosts/${DOMAIN}

	SetEnvIf X-Forwarded-Proto https HTTPS=on

	#RewriteEngine On
	#RewriteCond %{HTTP_HOST} ^${DOMAIN}
	#RewriteRule ^(.*)$ http://www.${DOMAIN} [R=301,L]

        <Directory /var/www/vhosts/${DOMAIN}>
                Options -Indexes +FollowSymLinks -MultiViews
                AllowOverride All
		Order deny,allow
		Allow from all
        </Directory>
        CustomLog /var/log/${APACHE_NAME}/${DOMAIN}-access.log combined
        ErrorLog /var/log/${APACHE_NAME}/${DOMAIN}-error.log
        # New Relic PHP override
        <IfModule php5_module>
               php_value newrelic.appname ${DOMAIN}
        </IfModule>
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
</VirtualHost>

##
# To install the SSL certificate, please place the certificates in the following files:
# >> SSLCertificateFile    /etc/pki/tls/certs/${DOMAIN}.crt
# >> SSLCertificateKeyFile    /etc/pki/tls/private/${DOMAIN}.key
# >> SSLCACertificateFile    /etc/pki/tls/certs/${DOMAIN}.ca.crt
#
# After these files have been created, and ONLY AFTER, then run this and restart Apache:
#
# To remove these comments and use the virtual host, use the following:
# VI   -  :39,$ s/^#//g
# RedHat Bash -  sed -i '39,$ s/^#//g' /etc/httpd/vhost.d/${DOMAIN}.conf && service httpd reload
# Debian Bash -  sed -i '39,$ s/^#//g' /etc/apache2/sites-available/${DOMAIN} && service apache2 reload
##

#<VirtualHost _default_:443>
#        ServerName ${DOMAIN}
#        ServerAlias www.${DOMAIN}
#        DocumentRoot /var/www/vhosts/${DOMAIN}
#        <Directory /var/www/vhosts/${DOMAIN}>
#                Options -Indexes +FollowSymLinks -MultiViews
#                AllowOverride All
#        </Directory>
#
#        CustomLog /var/log/${APACHE_NAME}/${DOMAIN}-ssl-access.log combined
#        ErrorLog /var/log/${APACHE_NAME}/${DOMAIN}-ssl-error.log
#
#        # Possible values include: debug, info, notice, warn, error, crit,
#        # alert, emerg.
#        LogLevel warn
#
#        SSLEngine on
#        SSLCertificateFile    ${SSL_PATH}/certs/2016-${DOMAIN}.crt
#        SSLCertificateKeyFile ${SSL_PATH}/private/2016-${DOMAIN}.key
#        SSLCACertificateFile  ${SSL_PATH}/certs/2016-${DOMAIN}.ca.crt
#
#        <IfModule php5_module>
#                php_value newrelic.appname ${DOMAIN}
#        </IfModule>
#        <FilesMatch \"\.(cgi|shtml|phtml|php)$\">
#                SSLOptions +StdEnvVars
#        </FilesMatch>
#
#        BrowserMatch \"MSIE [2-6]\" \
#                nokeepalive ssl-unclean-shutdown \
#                downgrade-1.0 force-response-1.0
#        BrowserMatch \"MSIE [17-9]\" ssl-unclean-shutdown
#</VirtualHost>
EOF

echo ""
echo "Virtual Host: ${DOMAIN} www.${DOMAIN}";
echo "Configuration File: ${CONFIG_PATH}/${DOMAIN}.conf";
echo "Document Root: /var/www/vhosts/${DOMAIN}";
echo ""

if [ ! -d /var/www/vhosts/${DOMAIN} ]; then 
    mkdir /var/www/vhosts/${DOMAIN}; 
else
    echo "Fatal: Document root already exists, exiting."; exit;
fi
#systemctl reload httpd
