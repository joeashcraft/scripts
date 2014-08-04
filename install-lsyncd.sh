if [ -f /etc/redhat-release ]; then
yum -y install lua lua-devel pkgconfig gcc asciidoc && \
wget -O /root/lsyncd-2.1.5.tar.gz https://lsyncd.googlecode.com/files/lsyncd-2.1.5.tar.gz && \ 
tar -xvzf lsyncd-2.1.5.tar.gz && \
cd lsyncd-2.1.5 && \ 
./configure && make && make install && \
mkdir /var/log/lsyncd && \
cat << 'EOF' > /etc/logrotate.d/lsyncd 
/var/log/lsyncd/*log {
  missingok
  notifempty
  sharedscripts
  postrotate
  if [ -f /var/lock/lsyncd ]; then
    /sbin/service lsyncd restart > /dev/null 2>/dev/null || true
  fi
  endscript
}
EOF
cat << 'EOF' > /etc/init.d/lsyncd
#!/bin/bash
#
# lsyncd: Starts the lsync Daemon
#
# chkconfig: 345 99 90
# description: Lsyncd uses rsync to synchronize local directories with a remote
# machine running rsyncd. Lsyncd watches multiple directories
# trees through inotify. The first step after adding the watches
# is to, rsync all directories with the remote host, and then sync
# single file buy collecting the inotify events.
# processname: lsyncd

. /etc/rc.d/init.d/functions

config="/etc/lsyncd.lua"
lsyncd="/usr/local/bin/lsyncd"
lockfile="/var/lock/subsys/lsyncd"
pidfile="/var/run/lsyncd.pid"
prog="lsyncd"
RETVAL=0

start() {
    if [ -f $lockfile ]; then
        echo -n $"$prog is already running: "
        echo
        else
        echo -n $"Starting $prog: "
        daemon $lsyncd -pidfile $pidfile $config
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch $lockfile
        return $RETVAL
    fi
}

stop() {
    echo -n $"Stopping $prog: "
    killproc $lsyncd
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f $lockfile
    return $RETVAL
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    status)
        status $lsyncd
        ;;
    *)
        echo "Usage: lsyncd {start|stop|restart|status}"
        exit 1
esac

exit $?
EOF
chown root /etc/init.d/lsyncd
chmod 755 /etc/init.d/lsyncd
chkconfig lsyncd on
cat << 'EOF' > /etc/lsyncd.lua
settings {
   logfile = "/var/log/lsyncd/lsyncd.log",
   statusFile = "/var/log/lsyncd/lsyncd-status.log",
   statusInterval = 20
}

servers = {
 "web02",
 "web03"
}

for _, server in ipairs(servers) do
sync {
    default.rsync,
    source="/var/www/",
    target=server..":/var/www/",
    rsync = {
        compress = true,
        archive = true,
        verbose = true,
        rsh = "/usr/bin/ssh -p 22 -o StrictHostKeyChecking=no"
    }
}
end
EOF
fi
if [ -f /etc/debian_version ]; then
apt-get install -y make lua5.1 liblua5.1-dev pkg-config rsync asciidoc && \
wget -O /root/lsyncd-2.1.5.tar.gz https://lsyncd.googlecode.com/files/lsyncd-2.1.5.tar.gz && \
tar -xvzf lsyncd-2.1.5.tar.gz && \
cd lsyncd-2.1.5 && \ 
./configure && make && make install && \
mkdir /var/log/lsyncd && \
cat << 'EOF' > /etc/logrotate.d/lsyncd 
/var/log/lsyncd/*log {
  missingok
  notifempty
  sharedscripts
  postrotate
  if [ -f /var/lock/lsyncd ]; then
    /sbin/service lsyncd restart > /dev/null 2>/dev/null || true
  fi
  endscript
}
EOF
cat << 'EOF' > /etc/init/lsyncd.conf
description "lsyncd file syncronizer"
 
start on (starting network-interface
 or starting network-manager
 or starting networking)
   
stop on runlevel [!2345]
   
expect fork
   
respawn
respawn limit 10 5
   
exec /usr/local/bin/lsyncd -pidfile /var/run/lsyncd.pid /etc/lsyncd.lua
EOF
ln -s /lib/init/upstart-job /etc/init.d/lsyncd && \
cat << 'EOF' > /etc/lsyncd.lua
settings {
   logfile = "/var/log/lsyncd/lsyncd.log",
   statusFile = "/var/log/lsyncd/lsyncd-status.log",
   statusInterval = 20
}

servers = {
 "web02",
 "web03"
}

for _, server in ipairs(servers) do
sync {
    default.rsync,
    source="/var/www/",
    target=server..":/var/www/",
    rsync = {
        compress = true,
        archive = true,
        verbose = true,
        rsh = "/usr/bin/ssh -p 22 -o StrictHostKeyChecking=no"
    }
}
end
EOF
fi
