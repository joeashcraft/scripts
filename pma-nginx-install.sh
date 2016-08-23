if [ -f /etc/redhat-release ]; then
    #echo "Red Hat Environment Detected...";
    echo -e "RHEL not supported... yet!";
    exit;
fi

if [ -f /etc/debian_version ]; then
    #echo "Debian Environment Detected...";
    
    ## Disable Apache and prepare boot up.
    service apache2 stop
    ansible-playbook ~/lamp/site-cookbooks/LAMP/files/default/lamp/nginx_deploy.yml -i lamp/site-cookbooks/LAMP/files/default/lamp/hosts
    update-rc.d apache2 disable
    update-rc.d nginx enable
    update-rc.d php5-fpm defaults
    update-rc.d php5-fpm enable
    
    ## Setup Nginx for phpMyAdmin.
    mkdir /etc/nginx/include.d
    cat << EOF > /etc/nginx/include.d/phpmyadmin.conf
location ~ /phpmyadmin { 
    root /usr/share;
    index index.php;

    auth_basic "phpMyAdmin Login";
    auth_basic_user_file /etc/phpmyadmin/phpmyadmin-htpasswd;

    location ~ \.php$ { 
        try_files \$uri =404;
        include fastcgi_params;
        fastcgi_pass   php5-fpm-sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param  HTTPS \$x_https;
    } 
}
EOF

## Add include to default virtual host.
cat << EOF > /etc/nginx/conf.d/000-default.conf
server {

    listen   80;

    ### Enable SSL
    #listen  443;
    #ssl on;
    #ssl_certificate cert.pem;
    #ssl_certificate_key cert.key;
    #ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    #ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
    #ssl_prefer_server_ciphers on;

    server_name  default;
    #server_name www.default;
    root /var/www/html;

    access_log  /var/log/nginx/access.log;
    error_log   /var/log/nginx/error.log error;

    include include.d/phpmyadmin.conf;

    location / {
        index  index.php index.html index.htm;
        try_files \$uri \$uri/ /index.php?q=\$uri&args;

    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_pass   php5-fpm-sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
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
#    server_name www.default;
#    rewrite ^ http://default\$request_uri? permanent;
#
#}
EOF
    
    ## Give Nginx same powers as Apache
    usermod -G www-data nginx
    
    ## Grab mcrypt PHP library because phpMyAdmin will complain
    php5enmod mcrypt
    service php5-fpm restart
fi
