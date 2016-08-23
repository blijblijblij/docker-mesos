#!/bin/sh

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
MESOS_MASTER_1=$(docker-machine ip mesos-master-1)
MESOS_MASTER_2=$(docker-machine ip mesos-master-2)
MESOS_MASTER_3=$(docker-machine ip mesos-master-3)
ZK=${MESOS_MASTER_1}:2181,${MESOS_MASTER_2}:2181,${MESOS_MASTER_3}:2181

echo "start mesos-master-2"
docker-machine env mesos-master-2
eval "$(docker-machine env mesos-master-2)"

echo "---> killall and clean"
docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)

echo "---> start zookeeper"
docker run -d \
	-e MYID=2 \
	-e SERVERS=${MESOS_MASTER_1},${MESOS_MASTER_2},${MESOS_MASTER_3} \
	--name=zookeeper --net=host --restart=always \
	mesoscloud/zookeeper:3.4.6-ubuntu-14.04

echo "---> start mesos master"
docker run -d \
	-e CLUSTER_SECRET=${CLUSTER_SECRET} \
	-e MESOS_CLUSTER=${CLUSTERNAME} \
	-e MESOS_HOSTNAME=${MESOS_MASTER_2} \
	-e MESOS_IP=${MESOS_MASTER_2} \
	-e MESOS_QUORUM=2 \
	-e MESOS_ZK=zk://${ZK}/mesos \
	--name mesos-master --net host --restart always  \
	mesosphere/mesos-master:1.0.0-2.0.89.ubuntu1404

echo "---> start marathon"
docker run -d \
	-e CLUSTER_SECRET=${CLUSTER_SECRET} \
	-e MARATHON_HOSTNAME=${MESOS_MASTER_2} \
	-e MARATHON_HTTPS_ADDRESS=${MESOS_MASTER_2} \
	-e MARATHON_HTTP_ADDRESS=${MESOS_MASTER_2} \
	-e MARATHON_MASTER=zk://${ZK}/mesos \
	-e MARATHON_ZK=zk://${ZK}/marathon \
	-e MARATHON_EVENT_SUBSCRIBER="http_callback" \
	-e MARATHON_TASK_LAUNCH_TIMEOUT="300000" \
	--name marathon --net host --restart always \
	mesosphere/marathon:v1.3.0-RC4

echo "---> start chronos"
docker run -d  \
	-e CHRONOS_HTTP_PORT=4400 \
	-e CHRONOS_MASTER=zk://${ZK}/mesos \
	-e CHRONOS_ZK_HOSTS=${ZK} \
	--name chronos --net host --restart always \
	mesosphere/chronos:chronos-2.5.0-0.1.20160223054243.ubuntu1404-mesos-0.27.1-2.0.226.ubuntu1404 \
	/usr/bin/chronos run_jar --http_port ${CHRONOS_HTTP_PORT} --zk_hosts ${CHRONOS_ZK_HOSTS} --master ${CHRONOS_MASTER}
