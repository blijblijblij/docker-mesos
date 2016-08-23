#!/bin/sh

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
MESOS_MASTER_1=$(docker-machine ip mesos-master-1)
MESOS_MASTER_2=$(docker-machine ip mesos-master-2)
MESOS_MASTER_3=$(docker-machine ip mesos-master-3)
ZK=${MESOS_MASTER_1}:2181,${MESOS_MASTER_2}:2181,${MESOS_MASTER_3}:2181

echo "start mesos-lb-1"
docker-machine env mesos-lb-1
eval "$(docker-machine env mesos-lb-1)"
docker rm -f proxy

docker run -d \
  -e MARATHON_IPS="${MESOS_MASTER_1} ${MESOS_MASTER_2} ${MESOS_MASTER_3}" \
  --name proxy --net host --pid host --restart always \
  indigodatacloud/haproxy-marathon-bridge
