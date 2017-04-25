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

    ## Modify nginx.conf and add x-forwarded-proto catch.
    cat << EOF > /etc/nginx/nginx.conf
user  www-data;
worker_processes  8;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    access_log  /var/log/nginx/access.log;

    sendfile        on;
    tcp_nopush     on;
    tcp_nodelay     on;

    keepalive_timeout  65;

    gzip  on;
    gzip_comp_level 2;
    gzip_buffers 16 8k;
    gzip_proxied any;
    gzip_types      text/plain text/css application/x-javascript application/xml application/xml+rss text/javascript application/json;
    gzip_http_version 1.0;
    gzip_disable "msie6";

    # Set real IP addr from Cloud Loud Balancers
    set_real_ip_from 10.183.248.0/22;
    set_real_ip_from 10.183.252.0/23;
    set_real_ip_from 10.190.254.0/23;
    set_real_ip_from 10.189.254.0/23;
    #set_real_ip_from 127.0.0.1;
    real_ip_header X-Forwarded-For;

    upstream php5-fpm-sock {
        server unix:/var/run/php5-fpm.sock;
    }

    map \$http_x_forwarded_proto \$x_https {
        default off;
        https on;
    }

    include /etc/nginx/conf.d/*.conf;
}
EOF
    
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
