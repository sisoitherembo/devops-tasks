Tutorial:
- To start an application without docker compose - execute "$ ./start_docker.sh" script 
- To start an application without docker compose and to push built images to DockerHub - execute "$ ./start_docker.sh push_images" 
- To stop an application without docker compose - execute "$ ./stop_docker.sh" script
- To start an appication with docker compose - execute "$ docker compose up" in shell
Be sure that host_mountpoint used correctly. Host_mountpoint is "nginx-user" folder on your host

Tutorial to Ansible-playbook:
- cd to ansible-playbooks folder and then run "$ source ./activate" to import env variables
- run "$ ansible-playbook nginx-deploy.yml" to deploy application in docker containers on defined hosts