#!/usr/bin/env sh

if [ ! -f /etc/ssh/ssh_host_rsa_key ] ; then
# Generate ssh key
    sudo ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ""
    sudo ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ""
    sudo ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ""
    sudo ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -q -N ""
fi

if [ "$@" = ""]; then
    sudo /bin/sshd -D
else
    sudo /bin/sshd -D &
    $@
fi