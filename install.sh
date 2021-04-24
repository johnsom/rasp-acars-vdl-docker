#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "The install script must be run as root."
  exit 1
fi

mkdir -p /var/log/containers
if ! grep -q '/var/log/containers' /etc/fstab; then
    echo "tmpfs   /var/log/containers     tmpfs   rw,size=1G,nodev,nosuid,noexec,uid=root,gid=syslog,mode=775 0 0" >> /etc/fstab
fi
mount -a
cp 30-acars-vdl-rsyslog.conf /etc/rsyslog.d
cp acars-vdlm2-logrotate /etc/logrotate.d
systemctl restart rsyslog
