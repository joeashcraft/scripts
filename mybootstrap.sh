apvhost () {
    bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/apache-create-virtualhost.sh") $1
}

kicklamp () {
    #bash <(curl -s "https://raw.githubusercontent.com/tbr0/scripts/master/ansible-lamp.sh")
    if [ -f /etc/redhat-release ]; then
      yum install -y git python-pip python-devel gcc openssl-devel
      #pip install paramiko PyYAML jinja2 httplib2 ansible
      pip install pip --upgrade
      pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe --upgrade
      #git clone https://github.com/rillip3/lamp.git
      git clone https://github.com/rackerlabs/lamp.git
      cd lamp/site-cookbooks/LAMP/files/default/lamp
      ansible-playbook -i hosts site.yml
    fi
    if [ -f /etc/debian_version ]; then
      apt-get update && apt-get install python-markupsafe python-apt libffi-dev python-pip build-essential python-dev git -y
      pip install pip --upgrade
      pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe
      pip install paramiko PyYAML jinja2 httplib2 ansible==1.6.1 markupsafe --upgrade
      #git clone https://github.com/rillip3/lamp.git
      git clone https://github.com/rackerlabs/lamp.git
      cd lamp/site-cookbooks/LAMP/files/default/lamp
      ansible-playbook -i hosts site.yml
    fi

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

installvsftpd () {

if [ -f /etc/redhat-release ]; then
    myversion=$(awk '{print $3}' /etc/redhat-release | awk -F'.' '{print $1}')
    if [ "$myversion" -eq 6 ]; then
        echo "RHEL 6 Here"
    fi
    yum -y install vsftpd
    chkconfig vsftpd on
    > /etc/vsftpd/vsftpd.conf
    sed -i -e 's/IPTABLES_MODULES=""/IPTABLES_MODULES="ip_conntrack_ftp"/g' /etc/sysconfig/iptables-config
    modprobe ip_conntrack_ftp
    cat << EOF > /etc/vsftpd.conf
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
pasv_min_port=60000
pasv_max_port=65000
EOF
     service vsftpd start
fi

if [ -f /etc/debian_version ]; then

echo "Debian here"

fi

}

lsyncdmaas () {
    git clone https://github.com/stevekaten/cloud-monitoring-plugin-deploy
    cd cloud-monitoring-plugin-deploy
    ansible-playbook -i hosts lsyncd_status.yml
}
getrackcli () {
    wget -O /opt/rack "https://ec4a542dbf90c03b9f75-b342aba65414ad802720b41e8159cf45.ssl.cf5.rackcdn.com/1.2/Linux/amd64/rack"
    chmod +x /opt/rack
    ln -s /opt/rack /usr/bin/rack
}
codedeploybootstrap () {
    # placeholder
}
