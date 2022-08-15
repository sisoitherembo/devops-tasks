#!/bin/bash
nginx_port_mapping="80:80"
apache_port_mapping="8080:80"
network="my-net"
ids=$(docker ps -qa)
login="sisoitherembo"
if [ "$ids" ]; then
    docker rm -f $ids
fi

cd apache-config && docker build -f apache.dockerfile -t $login/apache-app:latest . && cd ..
cd nginx-config && docker build -f nginx.dockerfile -t $login/nginx-app:latest . && cd ..
docker run -d -p $apache_port_mapping --name apache-app --network $network apache-app:latest 
docker run -p $nginx_port_mapping  --network $network --name nginx-app -v /mnt/d/nginx-user:/home/nginx-user -d  nginx:latest