SALT=`curl -sk https://api.wordpress.org/secret-key/1.1/salt/`
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/vhosts/${DOMAIN}/wp-config.php
#echo ${WP_SALT}
