FROM nginx:1.22.0-alpine as nginx-app

ENV USER=nginx-user
ENV HOME=/home/${USER}

EXPOSE 80:80/tcp
EXPOSE 8080/tcp
EXPOSE 8081/tcp
EXPOSE 8082/tcp
WORKDIR ${HOME}

COPY nginx.conf /etc/nginx/nginx.conf
COPY roundrobin.conf /etc/nginx/conf.d/round.conf
COPY server.conf /etc/nginx/conf.d/default.conf

RUN  adduser -D ${USER} \
        && addgroup ${USER} ${USER} 
       
COPY --chown=${USER}:${USER} ./nginx-user ${HOME}
COPY scripts/40-daemon.sh /docker-entrypoint.d/40-nginx-log-daemon.sh
COPY scripts/nginx-log-daemon.sh /home/
RUN chmod +x /home/nginx-log-daemon.sh
RUN chmod +x /docker-entrypoint.d/40-nginx-log-daemon.sh

CMD ["nginx", "-g", "daemon off;" ]
