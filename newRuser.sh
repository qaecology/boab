#!/bin/bash

set -e

if [[ `/usr/bin/id -u` -ne 0 ]]; then
  echo "Not running as root"
  exit
fi

root=TRUE
mem=32G

while getopts 'r:m:' opt ; do
  case $opt in
    r) root=$OPTARG ;;
    m) mem=$OPTARG ;;
  esac
done

shift $((OPTIND-1)) 

con='\e[0;31m'
cof='\e[0m'

if [ $# -lt 1 ]; then
  echo "Usage: $0 [options] user"
  echo -e "Options: -r root (def: $root) | -m memory-limit (def: $mem)"
  exit 1
fi

user=$1

uid=$(id -u "$user")

port_rstudio=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
port_ssh=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')

docker run -d \
  -p $port_rstudio:8787 \
  -p $port_ssh:22 \
  -m $mem \
  -v /var/lib/docker/vfs/dir/$user:/home/$user \
  -v /var/lib/sss/pipes/:/var/lib/sss/pipes/:rw \
  --name $user \
  -e USERID=$uid \
  -e ROOT=$root \
  --tmpfs /tmp:rw,exec,nosuid,size=100g \
  qaeco_lab

sleep 1

addSrvBlock.sh

echo -e 'You can access the RStudio server at '$con'http://boab.qaeco.com/'$user'-rstudio/'$cof
echo -e 'and the sftp server on port '$con$port_ssh$cof' at '$con$user'@boab.qaeco.com'$cof
echo -e 'using your University of Melbourne username and password'
