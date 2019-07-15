#!/bin/bash

USERID=${USERID:=1000}
ROOT=${ROOT:=FALSE}
export HOME=/home/$USER

useradd -u $USERID $USER
addgroup $USER staff
echo "$USER:$PASSWORD" | chpasswd
chmod go-rx /usr/bin/passwd
mkdir -p $HOME

echo -e "[user]\n\tname = $USER\n\temail = '<>'\n\n[credential]\n\thelper = cache --timeout=31536000\n" > $HOME/.gitconfig

if [ "$ROOT" == "TRUE" ]
  then
    adduser $USER sudo && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

env | cat >> /usr/local/lib/R/etc/Renviron

chown -R $USER:$USER $HOME
