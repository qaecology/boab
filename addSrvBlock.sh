#!/bin/bash

# exit the script if there is an error
set -e

# Check if we are running as root
if [[ `/usr/bin/id -u` -ne 0 ]]; then
  echo "Please run as root"
  exit
fi

# list all the docker containers running
export users=$(docker ps --format "{{.Names}}")

# count how many containers are running
export nUsers=$(docker ps --format "{{.Names}}" | wc -l)

# set the nginx conf file to update
export nginxconf=/etc/nginx/sites-available/boab.qaeco.com

# copy the first part of the default conf file to the new conf file
sed -e '/server_name/,$d' /etc/nginx/sites-available/default > $nginxconf

# add the server name
echo -e '\n\tserver_name boab.qaeco.com;\n' >> $nginxconf

# loop over the users
for i in `seq 0 $($nUsers-1)`; 

do
if [ "${users[i]}" = "boab_usage" ]; then continue; fi
# get the ports each user is using
export port_rstudio=$(docker port ${users[i]} 8787 | cut -d ":" -f 2-)

# add the reverse proxy block to the nginx conf file
echo -e '
\t location /'${users[i]}'-rstudio/ {
\t\t rewrite ^/'${users[i]}'-rstudio/(.*)$ /$1 break;
\t\t proxy_pass      http://localhost:'$port_rstudio';
\t\t proxy_redirect  http://localhost:'$port_rstudio'/ $scheme://$host/'${users[i]}'-rstudio/;
\t\t proxy_http_version 1.1;
\t\t proxy_set_header Upgrade $http_upgrade;
\t\t proxy_set_header Connection "upgrade";
\t\t proxy_connect_timeout       300;
\t\t proxy_send_timeout          300;
\t\t proxy_read_timeout          300;
\t\t send_timeout                300;
\t }
' >> $nginxconf

done

# add the end of the default nginx config file to the new config
sed -e '1,/server_name/d' /etc/nginx/sites-available/default >> $nginxconf

# restart nginx
systemctl reload nginx
