#!/bin/bash
if [ -f ~/.ssh/config ]
then
    echo "Bastion Disabled"
    mv ~/.ssh/config{,.disabled}
else
    echo "Bastion Enabled"
    mv ~/.ssh/config.disabled ~/.ssh/config
fi
