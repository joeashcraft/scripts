yum install nginx
yum install php54-fpm
sed -i "s|listen = 127.0.0.1:9000|listen = /var/run/php5-fpm.sock|" /etc/php-fpm.d/www.conf
service php-fpm start
mkdir /etc/nginx/global
cat << EOF > /etc/nginx/conf.d/php-upstream.conf
# Upstream to abstract backend connection(s) for PHP.
upstream php {
  #this should match value of "listen" directive in php-fpm pool
  server unix:/var/run/php5-fpm.sock;
  #server 127.0.0.1:9000;
}
EOF
cat << EOF > /etc/nginx/global/restrictions.conf
# Global restrictions configuration file.
# Designed to be included in any server {} block.</p>
location = /favicon.ico {
  log_not_found off;
  access_log off;
}
location = /robots.txt {
  allow all;
  log_not_found off;
  access_log off;
}
# Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
# Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
location ~ /\. {
  deny all;
}
# Deny access to any files with a .php extension in the uploads directory
# Works in sub-directory installs and also in multisite network
# Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
location ~* /(?:uploads|files)/.*\.php$ {
  deny all;
}
EOF
