#!/bin/sh
/home/nginx-log-daemon.sh  & 
sudo snap install -y --classic  certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot -n -d sisoi-k8s.ddns.net -m dmitri20023zarubo@gmail.com --nginx