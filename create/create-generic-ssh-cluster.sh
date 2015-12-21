#!/bin/sh
clear

clean() {
  echo "---> rm old machines" | lolcat
  docker-machine rm -f mesos-m1 mesos-m2 mesos-m3 mesos-s1 mesos-s2 mesos-s3 > /dev/null
}

create_masters() {
  echo "---> create masters" | lolcat
  echo "---> mesos-m1" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.20 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-m1

  echo "---> mesos-m2" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.21 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-m2

  echo "---> mesos-m3" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.22 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-m3
}

create_slaves() {
  echo "---> mesos-s1" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.23 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-s1

  echo "---> mesos-s2" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.24 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-s2

  echo "---> mesos-s3" | lolcat
  docker-machine create -d generic \
  --generic-ip-address 192.168.1.25 \
  --generic-ssh-key "$HOME/.ssh/blij" \
  --generic-ssh-port "22" \
  --generic-ssh-user "root" \
  mesos-s3
}


main() {
  echo "generic cluster" | figlet | lolcat
  clean
  create_masters
  create_slaves
  echo "done" | figlet | lolcat
}

main
