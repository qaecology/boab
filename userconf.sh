#!/bin/bash

export HOME=/home/$USER
mkdir -p $HOME

adduser $USER sudo && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

env | cat >> /usr/local/lib/R/etc/Renviron

chown -R $USER:$USER $HOME

