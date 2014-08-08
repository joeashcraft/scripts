if [ -f /etc/redhat-release ]; then
  rpm --nosignature -ivh http://repo.varnish-cache.org/redhat/varnish-3.0/el5/noarch/varnish-release/varnish-release-3.0-1.noarch.rpm
  myversion=$(awk '{print $3}' /etc/redhat-release | awk -F'.' '{print $1}')
  if [ "$myversion" -ne "5" ];then
    sed -i "s/el5/el$myversion/g" /etc/yum.repos.d/varnish.repo
    sed -i "s/Linux 5/Linux $myversion/g" /etc/yum.repos.d/varnish.repo
  fi
  yum -y install varnish
  wget -O- /etc/varnish/wordpress.vcl 
fi
if [ -f /etc/debian_version ]; then
  if [ $(lsb_release -c | awk '{print $2}') == "lucid" ];then
    echo "Executing apt-key addition: $(curl -sL http://repo.varnish-cache.org/debian/GPG-key.txt | apt-key add -)"
    echo "deb http://repo.varnish-cache.org/ubuntu/ lucid varnish-3.0" > /etc/apt/sources.list.d/varnish.list
  fi
  apt-get -q=2 update
  apt-get -y install varnish libvarnishapi1
fi
