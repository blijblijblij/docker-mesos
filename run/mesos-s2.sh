#!/bin/sh

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
MESOS_MASTER_1=$(docker-machine ip mesos-m1)
MESOS_MASTER_2=$(docker-machine ip mesos-m2)
MESOS_MASTER_3=$(docker-machine ip mesos-m3)
SLAVE_IP=$(docker-machine ip mesos-s2)
ZK=${MESOS_MASTER_1}:2181,${MESOS_MASTER_2}:2181,${MESOS_MASTER_3}:2181
MARATHON_VERSION=0.11.0
CHRONOS_VERSION=2.4.0
MESOS_VERSION=0.24.1
ZOOKEEPER_VERSION=3.4.6

echo "start mesos-s2" | figlet | lolcat
docker-machine env mesos-s2
eval "$(docker-machine env mesos-s2)"
docker rm -f slave

echo "---> start mesos slave" | lolcat
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MESOS_HOSTNAME=${SLAVE_IP} \
	-e MESOS_IP=${SLAVE_IP} \
	-e MESOS_MASTER=zk://${ZK}/mesos \
	-e MESOS_LOG_DIR=/var/log/mesos \
	-e MESOS_LOGGING_LEVEL=INFO \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--name slave --net host --privileged --restart always \
	mesoscloud/mesos-slave:${MESOS_VERSION}-ubuntu-14.04
