#!/bin/bash

if [ -f config-include.sh ]; then
    source config-include.sh
fi

# Purge all the exported vollumes
sudo rm -r /var/docker/aegir01

docker build -t $IMAGE_NAME .

# Remove the fingerprint from the known hosts file, 
# the updated container will have a different one.
ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R [localhost]:30022


