#!/bin/bash
dockerhub_login="sisoitherembo"
network="my-net"
host_mountpoint="/mnt/d/nginx-user"
container_mountpoint="/home/nginx-user"
nginx_name="nginx-app"
nginx_conf_dir="nginx-config"
nginx_dockerfile="nginx.dockerfile"
nginx_port_mapping="80:80"
apache_name="apache-app"
apache_conf_dir="apache-config"
apache_dockerfile="apache.dockerfile"
apache_port_mapping="8080:80"

ids=$(docker ps -a |  awk  '{ if ( $13 == "nginx-app" || $12 == "apache-app") print $1;}')
if [ -n "$ids" ]; then
    echo "Deleting existing containers..."
    docker rm -f $ids
fi

if [ -d $apache_conf_dir ]; then
    echo "Found apache-conf dir" && cd $apache_conf_dir 
    if [ -f $apache_dockerfile ]; then
        echo "Starting apache build..."
        docker build -f $apache_dockerfile -t $dockerhub_login/$apache_name:latest . && cd ..
        if [ $? == 1 ]; then 
            echo "Something went wrong when building apache.." && exit 1 
        fi
    fi
fi
if [ -d $nginx_conf_dir ]; then
    echo "Found nginx-conf dir" && cd $nginx_conf_dir
    if [ -f $nginx_dockerfile ]; then
        echo "Starting nginx build..."
        docker build -f $nginx_dockerfile -t $dockerhub_login/$nginx_name:latest . && cd ..
        if [ $? == 1 ]; then 
            echo "Something went wrong when building apache.." && exit 1 
        fi
    fi
fi
echo "Starting nginx-apache application..."
docker run -d -p $apache_port_mapping --name $apache_name --network $network $apache_name:latest \
    && docker run -p $nginx_port_mapping  --network $network --name $nginx_name -v $host_mountpoint:$container_mountpoint -d  $nginx_name:latest 
if [ $? == 1 ]; then 
    echo "Something went wrong when building apache.." && exit 1 
fi
echo "Finished successfully!"