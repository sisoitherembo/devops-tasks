#!/bin/bash
sudo apt-get install -y apache2
server_ip=$(hostname -I)
server_name=$(hostname)
cat > index.html <<EOF
<h1>Hello, World</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
<p>Server's IP address: $server_ip</p>
<p>Server's name: $server_name</p> 
EOF
sudo cp -fv index.html /var/www/html/index.html
sudo service apache2 start