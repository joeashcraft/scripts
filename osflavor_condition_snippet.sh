if [ -f /etc/redhat-release ]; then

    myversion=$(awk '{print $3}' /etc/redhat-release | awk -F'.' '{print $1}')
    echo "RHEL 7 Here"

    if [ "$myversion" -eq 6] then

    echo "RHEL 6 Here"

    fi
fi

if [ -f /etc/debian_version ]; then

echo "Debian here"

fi
