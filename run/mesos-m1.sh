#!/bin/sh

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
MESOS_MASTER_1=$(docker-machine ip mesos-m1)
MESOS_MASTER_2=$(docker-machine ip mesos-m2)
MESOS_MASTER_3=$(docker-machine ip mesos-m3)
ZK=${MESOS_MASTER_1}:2181,${MESOS_MASTER_2}:2181,${MESOS_MASTER_3}:2181
MARATHON_VERSION=0.11.0
CHRONOS_VERSION=2.4.0
MESOS_VERSION=0.24.1
ZOOKEEPER_VERSION=3.4.6

echo "start mesos-m1" | figlet | lolcat
docker-machine env mesos-m1
eval "$(docker-machine env mesos-m1)"
docker rm -f zookeeper mesos-master marathon chronos slave haproxy

echo "---> start zookeeper" | lolcat
docker run -d \
	-e MYID=1 \
	-e SERVERS=${MESOS_MASTER_1},${MESOS_MASTER_2},${MESOS_MASTER_3} \
	--name=zookeeper --net=host --restart=always \
	mesoscloud/zookeeper:${ZOOKEEPER_VERSION}-ubuntu-14.04

echo "---> start mesos master" | lolcat
docker run -d \
	-e MESOS_CLUSTER=${CLUSTERNAME} \
	-e SECRET=${CLUSTER_SECRET} \
	-e MESOS_HOSTNAME=${MESOS_MASTER_1} \
	-e MESOS_IP=${MESOS_MASTER_1} \
	-e MESOS_QUORUM=2 \
	-e MESOS_ZK=zk://${ZK}/mesos \
	--name mesos-master --net host --restart always  \
	mesoscloud/mesos-master:${MESOS_VERSION}-ubuntu-14.04

echo "---> start mesos slave" | lolcat
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MESOS_HOSTNAME=${MESOS_MASTER_1} \
	-e MESOS_IP=${MESOS_MASTER_1} \
	-e MESOS_MASTER=zk://${ZK}/mesos \
	-e MESOS_LOG_DIR=/var/log/mesos \
	-e MESOS_LOGGING_LEVEL=INFO \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--name slave --net host --privileged --restart always \
	mesoscloud/mesos-slave:${MESOS_VERSION}-ubuntu-14.04

echo "---> start marathon" | lolcat
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MARATHON_HOSTNAME=${MESOS_MASTER_1} \
	-e MARATHON_HTTPS_ADDRESS=${MESOS_MASTER_1} \
	-e MARATHON_HTTP_ADDRESS=${MESOS_MASTER_1} \
	-e MARATHON_MASTER=zk://${ZK}/mesos \
	-e MARATHON_ZK=zk://${ZK}/marathon \
	--name marathon --net host --restart always \
	mesoscloud/marathon:${MARATHON_VERSION}-ubuntu-15.04

echo "---> start chronos" | lolcat
docker run -d  \
	-e SECRET=${CLUSTER_SECRET} \
	-e CHRONOS_HTTP_PORT=4400 \
	-e CHRONOS_MASTER=zk://${ZK}/mesos \
	-e CHRONOS_ZK_HOSTS=${ZK} \
	--name chronos --net host --restart always \
	mesoscloud/chronos:${CHRONOS_VERSION}-ubuntu-14.04
