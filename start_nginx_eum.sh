#!/bin/bash
#nginx
#sh /home/eversafe/eversafe-update-manager/daemon.sh start

function wait_loop() {
  for i in $(seq $1)
  do
    sleep 1
    echo "wait " $i
  done
}
touch call_eum.info
su - eversafe -c "sh /home/eversafe/eversafe-update-manager/daemon.sh start"
wait_loop 1
touch call_nginx.info
su - eversafe -c "nginx"

/sbin/init
