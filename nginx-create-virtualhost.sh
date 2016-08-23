#!/bin/bash
DOMAIN=${1}
CONFIG_PATH=''
PARENT_ROOT='/var/www/vhosts'

if [ ! -d ${PARENT_ROOT} ]; then 
    echo "Notice: No ${PARENT_ROOT} folder found.";
fi

if [ -f /etc/redhat-release ]; then
    CONFIG_PATH="/etc/nginx/conf.d";
    #echo "Red Hat Environment Detected...";
    if [ ! -d ${CONFIG_PATH} ]; then 
        echo "Fatal: Cannot find ${CONFIG_PATH}, exiting.";
        exit;
    fi
fi
if [ -f /etc/debian_version ]; then
    CONFIG_PATH="/etc/nginx/conf.d";
    #echo "Debian Environment Detected...";
    if [ ! -d ${CONFIG_PATH} ]; then 
        echo "Fatal: Cannot find ${CONFIG_PATH}, exiting.";
        exit;
    fi
fi
if [ -z ${CONFIG_PATH} ]; then
    echo "Fatal: Could not determine configuration path for Nginx, exiting."; exit;
fi

cat << EOF > ${CONFIG_PATH}/${DOMAIN}.conf
server {
 
    listen   80; 
 
    ### Enable SSL
    #listen  443;
    #ssl on;
    #ssl_certificate cert.pem;
    #ssl_certificate_key cert.key;
    #ssl_protocols SSLv3 TLSv1;
    #ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
    #ssl_prefer_server_ciphers on;

    server_name  ${DOMAIN};
    server_name www.${DOMAIN};
    root /var/www/vhosts/${DOMAIN};

    access_log  /var/log/nginx/${DOMAIN}_access.log;
    error_log   /var/log/nginx/${DOMAIN}_error.log error;
 
    location / {
        index  index.php index.html index.htm;
        try_files \$uri \$uri/ /index.php?q=\$uri&args;
 
    }
 
    location ~ \.php$ {
        try_files \$uri =404;
        include fastcgi_params;
        fastcgi_pass   php5-fpm-sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param  HTTPS \$x_https;
    }
 
 
    ### Set Headers on Images and other Static Assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires 1y;
    log_not_found off;
    }
 
}


### For forced non-www redirects

#server {
#
#    listen   80;  
#    server_name www.${DOMAIN};
#    rewrite ^ http://${DOMAIN}\$request_uri? permanent;
#
#}
EOF

echo "Virtual Host: ${DOMAIN} www.${DOMAIN}";
echo "Configuration File: ${CONFIG_PATH}/${DOMAIN}.conf";
echo "Document Root: /var/www/vhosts/${DOMAIN}";
echo ""

if [ ! -d /var/www/vhosts/${DOMAIN} ]; then 
    mkdir /var/www/vhosts/${DOMAIN}; 
else
    echo "Fatal: Document root already exists, exiting."; exit;
fi
