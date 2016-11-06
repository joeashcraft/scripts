apvhost () {
    bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/apache-create-virtualhost.sh") $1
}

kicklamp () {
    bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/ansible-lamp.sh")
}

getpass () {
    bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/getpass.sh")
}

installtrove () {
    virtualenv trove;
    . trove/bin/activate;
    pip install --upgrade setuptools;
    pip install pytz;
    pip install python-troveclient rackspace-auth-openstack;
    echo "DDI:"; read DDI;
    echo "Region:(IAD,DFW, or ORD):"; read REGION
    echo "User:"; read USER;
    echo "Key:"; read KEY;
    echo "Database Host:"; read DB_HOST;
    echo "Database UUID:"; read DB_UUID;
    cat << EOF > .trove
export OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0/
export OS_REGION_NAME=${REGION}
export OS_AUTH_SYSTEM=rackspace
export OS_USERNAME=${USER}
export OS_TENANT_ID=${DDI}
export TROVE_SERVICE_TYPE=rax:database
export OS_PASSWORD=${KEY}
export OS_PROJECT_ID=${DDI}
export DB_HOST=${DB_HOST}
export DB_UUID=${DB_UUID}
EOF
    source .trove
}

trove-createdb () {
    bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/trove/dbaas_trove_create_database.sh") $1
}

rhel7-addrepos-epel-ius () {
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm -Uvh https://rhel7.iuscommunity.org/ius-release.rpm
}
