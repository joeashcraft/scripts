#!/bin/bash
DOMAIN=${1}
CONFIG_PATH=''

if [ ! -d /var/www/vhosts ]; then 
    echo "No parent folder for document root, has LAMP kick been installed? Continuing with Apache Virtual Host configuration...";
fi

if [ -f /etc/redhat-release ]; then
    CONFIG_PATH="/etc/httpd/vhost.d";
    echo "Red Hat Environment Detected...";
    if [ ! -d /etc/httpd/vhost.d ]; then 
        echo "No configuration directory for Apache, has LAMP kick been installed? Exiting...";
        exit;
    fi
fi
if [ -f /etc/debian_version ]; then
    CONFIG_PATH="/etc/apache2/sites-available";
    echo "Debian Environment Detected...";
    if [ ! -d /etc/apache2/sites-available ]; then 
        echo "No configuration directory for Apache, has LAMP kick been installed? Exiting...";
        exit;
    fi
fi
if [ -z ${CONFIG_PATH} ]; then
    echo "Could not determine configuration path for Apache, exiting.."; exit;
fi

echo "Configuration path: ${CONFIG_PATH}/${DOMAIN}"

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
        CustomLog /var/log/httpd/${DOMAIN}-access.log combined
        ErrorLog /var/log/httpd/${DOMAIN}-error.log
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
#        CustomLog /var/log/httpd/${DOMAIN}-ssl-access.log combined
#        ErrorLog /var/log/httpd/${DOMAIN}-ssl-error.log
#
#        # Possible values include: debug, info, notice, warn, error, crit,
#        # alert, emerg.
#        LogLevel warn
#
#        SSLEngine on
#        SSLCertificateFile    /etc/pki/tls/certs/2014-${DOMAIN}.crt
#        SSLCertificateKeyFile /etc/pki/tls/private/2014-${DOMAIN}.key
#        SSLCACertificateFile /etc/pki/tls/certs/2014-${DOMAIN}.ca.crt
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

echo "Virtual Host configured:"
echo "========================"
echo "Virtual Host: ${DOMAIN}";
echo "Configuration File: ${CONFIG_PATH}/${DOMAIN}.conf";
echo "Document Root: /var/www/vhosts/${DOMAIN}";
echo "========================"

if [ ! -d /var/www/vhosts/${DOMAIN} ]; then 
    mkdir /var/www/vhosts/${DOMAIN}; 
else
    echo "Document root exists, not creating folder but configuration exists, exiting..."; exit;
fi
#systemctl reload httpd
