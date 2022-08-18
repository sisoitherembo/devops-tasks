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

echo "Starting our app..."

echo "Building our images..."
if [ -d $apache_conf_dir ]; then
    echo "Found apache-conf dir" && cd $apache_conf_dir 
    if [ -f $apache_dockerfile ]; then
        echo "Starting apache build..."
        docker build -f $apache_dockerfile -t $dockerhub_login/$apache_name:latest . && cd ..
        if [ $? == 1 ]; then 
            echo "Something went wrong when building apache.." && exit 1 
        elif [ "$1" == "push_images" ]; then
            echo "Pushing apache image to dockerhub"
            docker push $dockerhub_login/$apache_name:latest
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
        elif [ "$1" == "push_images" ]; then
            echo "Pushing nginx image to dockerhub"
            docker push $dockerhub_login/$nginx_name:latest
        fi
    fi
fi

echo "Checking for name conflicts..."
ids=$(docker ps -a |  awk -vAPP1=$nginx_name -vAPP2=$apache_name '{ if ( $13 == APP1 || $12 == APP2 ) print $1;}')
if [ -n "$ids" ]; then
    echo "Found name conflicts! Deleting existing containers..."
    docker rm -f $ids
fi

echo "Starting nginx-apache application..."
docker run -d -p $apache_port_mapping --name $apache_name --network $network $dockerhub_login/$apache_name:latest \
    && docker run -p $nginx_port_mapping  --network $network --name $nginx_name -d  $dockerhub_login/$nginx_name:latest 
if [ $? == 1 ]; then 
    echo "Something went wrong when building apache.." && exit 1 
fi
echo "Finished successfully!"