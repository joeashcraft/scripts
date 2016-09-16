PUBLIC_IPV4=$(ip a show dev eth0| grep "inet " | awk '{print $2}' | sed s=/\.*==)
PMA_USER=$(awk '{print $1}' /root/.phpmyadminpass)
PMA_PASSWORD=$(awk '{print $2}' /root/.phpmyadminpass)
MYSQL_USER=grep "user" /root/.my.cnf | grep -v "#user" | awk -F "=" '{print $2}'
MYSQL_PASSWORD=grep "password" /root/.my.cnf | grep -v "#password" | awk -F "=" '{print $2}'

echo "phpMyAdmin"
echo "Host: http://${PUBLIC_IPV4}/phpmyadmin"
echo "User: ${PMA_USER}"
echo "Password: ${PMA_PASSWORD}"
echo ""
echo "MySQL"
echo "User: ${MYSQL_USER}"
echo "Password: ${MYSQL_PASSWORD}"
echo ""
