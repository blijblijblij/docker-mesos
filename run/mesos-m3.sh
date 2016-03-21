#!/bin/sh

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
MESOS_MASTER_1=$(docker-machine ip mesos-m1)
MESOS_MASTER_2=$(docker-machine ip mesos-m2)
MESOS_MASTER_3=$(docker-machine ip mesos-m3)
ZK=${MESOS_MASTER_1}:2181,${MESOS_MASTER_2}:2181,${MESOS_MASTER_3}:2181

echo "start mesos-m3" | figlet | lolcat
docker-machine env mesos-m3
eval "$(docker-machine env mesos-m3)"
docker rm -f zookeeper mesos-master marathon chronos

echo "---> start zookeeper" | lolcat
docker run -d \
	-e MYID=3 \
	-e SERVERS=${MESOS_MASTER_1},${MESOS_MASTER_2},${MESOS_MASTER_3} \
	--name=zookeeper --net=host --restart=always \
	mesoscloud/zookeeper:3.4.6-ubuntu-14.04

echo "---> start mesos master" | lolcat
docker run -d \
	-e MESOS_CLUSTER=${CLUSTERNAME} \
	-e SECRET=${CLUSTER_SECRET} \
	-e MESOS_HOSTNAME=${MESOS_MASTER_3} \
	-e MESOS_IP=${MESOS_MASTER_3} \
	-e MESOS_QUORUM=2 \
	-e MESOS_ZK=zk://${ZK}/mesos \
	--name mesos-master --net host --restart always  \
	mesosphere/mesos-master:0.26.0-0.2.145.ubuntu1404

echo "---> start marathon" | lolcat
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MARATHON_HOSTNAME=${MESOS_MASTER_3} \
	-e MARATHON_HTTPS_ADDRESS=${MESOS_MASTER_3} \
	-e MARATHON_HTTP_ADDRESS=${MESOS_MASTER_3} \
	-e MARATHON_MASTER=zk://${ZK}/mesos \
	-e MARATHON_ZK=zk://${ZK}/marathon \
	-e MARATHON_EVENT_SUBSCRIBER="http_callback" \
	-e MARATHON_TASK_LAUNCH_TIMEOUT="300000" \
	--name marathon --net host --restart always \
	mesosphere/marathon:v0.15.3

echo "---> start chronos" | lolcat
docker run -d  \
	-e SECRET=${CLUSTER_SECRET} \
	-e CHRONOS_HTTP_PORT=4400 \
	-e CHRONOS_MASTER=zk://${ZK}/mesos \
	-e CHRONOS_ZK_HOSTS=${ZK} \
	--name chronos --net host --restart always \
	mesoscloud/chronos:2.4.0-ubuntu-14.04
