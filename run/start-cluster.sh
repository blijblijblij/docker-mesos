#!/bin/sh

echo "start cluster" | figlet | lolcat

main() {
  clear
  sh mesos-m1.sh
  sh mesos-m2.sh
  sh mesos-m3.sh
  # sh mesos-s1.sh
  # sh mesos-s2.sh
  # sh mesos-s3.sh
  echo "done" | figlet | lolcat
}

main
