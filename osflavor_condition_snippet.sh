#!/bin/bash
if [ -f /etc/redhat-release ]; then
    myversion=$(awk -F 'release' '{print $2}' /etc/redhat-release | tr -d " "| awk -F'.' '{print $1}')
    if [ "$myversion" -eq 7 ]; then

    echo "RHEL 7 Here"

    fi
    if [ "$myversion" -eq 6 ]; then

    echo "RHEL 6 Here"

    fi
fi

if [ -f /etc/debian_version ]; then
    if [ $(cat /etc/debian_version) = "jessie/sid" ]; then

        echo "Ubuntu 14.04"

    fi
    if [ $(cat /etc/debian_version) = "stretch/sid" ]; then

        echo "Ubuntu 16.04"

    fi
fi
