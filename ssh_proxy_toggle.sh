#!/bin/bash
if [ -f ~/.ssh/config ]
then
    mv ~/.ssh/config{,.disabled}
else
    mv ~/.ssh/config.disabled ~/.ssh/config
fi
