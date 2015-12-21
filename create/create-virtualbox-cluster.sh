#!/bin/sh
clear

echo "local cluster" | figlet | lolcat

clean() {
  echo "---> rm old machines" | lolcat
  docker-machine rm -f mesos-m1 mesos-m2 mesos-m3 mesos-s1 mesos-s2 > /dev/null
}

create_masters() {
  echo "---> create masters" | lolcat
  echo "---> create mesos-m1" | lolcat
  docker-machine create -d virtualbox \
    --virtualbox-cpu-count "1" \
    --virtualbox-memory "1024" \
    --virtualbox-disk-size "50000" \
    mesos-m1

  echo "---> create mesos-m2" | lolcat
  docker-machine create -d virtualbox \
    --virtualbox-cpu-count "1" \
    --virtualbox-memory "1024" \
    --virtualbox-disk-size "50000" \
    mesos-m2

  echo "---> create mesos-m3" | lolcat
  docker-machine create -d virtualbox \
    --virtualbox-cpu-count "1" \
    --virtualbox-memory "1024" \
    --virtualbox-disk-size "50000" \
    mesos-m3
}

create_slaves() {
  echo "---> create slaves" | lolcat
  echo "---> create mesos-s1" | lolcat
  docker-machine create -d virtualbox \
    --virtualbox-cpu-count "2" \
    --virtualbox-memory "4092" \
    --virtualbox-disk-size "50000" \
    mesos-s1

  echo "---> create mesos-s2" | lolcat
  docker-machine create -d virtualbox \
      --virtualbox-cpu-count "2" \
      --virtualbox-memory "4092" \
      --virtualbox-disk-size "50000" \
      mesos-s2
}
main() {
  clean
  create_masters
  create_slaves
  echo "done" | figlet | lolcat
}

main
