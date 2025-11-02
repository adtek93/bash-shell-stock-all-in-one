#!/bin/bash
ipv4=$(hostname -I | awk '{print $1}')
echo -ne '\n' 
ssh-keygen
ssh-copy-id root@$ipv4
cat ~/.ssh/id_rsa.pub | ssh root@$ipv4 "mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chmod -R go= ~/.ssh && cat >> ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub
mkdir -p ~/.ssh
echo public_key_string >> ~/.ssh/authorized_keys
chmod -R go= ~/.ssh
chown -R root:root ~/.ssh