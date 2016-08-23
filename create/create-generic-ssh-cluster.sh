#!/bin/sh
clear

clean() {
  echo "---> rm old machines" | lolcat
  docker-machine rm -f mesos-master-1 mesos-master-2 mesos-master-3 mesos-agent-1 mesos-agent-2 mesos-agent-3 mesos-lb-1 > /dev/null
}

create_masters() {
  echo "---> create masters" | lolcat
  echo "---> mesos-master-1" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.103 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-master-1

  echo "---> mesos-master-2" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.141 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-master-2

  echo "---> mesos-master-3" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.226 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-master-3
}

create_slaves() {
  echo "---> mesos-agent-1" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.154 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-agent-1

  echo "---> mesos-agent-2" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.215 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-agent-2

  echo "---> mesos-agent-3" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.... \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-agent-3
}

create_loadbalancer() {
  echo "---> mesos-lb-1" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.247 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-lb-1
}

main() {
  echo "generic cluster" | figlet | lolcat
  clean
  create_masters
  create_slaves
  create_loadbalancer
  echo "done" | figlet | lolcat
}

main
