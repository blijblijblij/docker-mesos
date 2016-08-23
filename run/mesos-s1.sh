#!/bin/sh

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
MESOS_MASTER_1=$(docker-machine ip mesos-master-1)
MESOS_MASTER_2=$(docker-machine ip mesos-master-2)
MESOS_MASTER_3=$(docker-machine ip mesos-master-3)
SLAVE_IP=$(docker-machine ip mesos-agent-1)
ZK=${MESOS_MASTER_1}:2181,${MESOS_MASTER_2}:2181,${MESOS_MASTER_3}:2181

echo "start mesos-agent-1"
docker-machine env mesos-agent-1
eval "$(docker-machine env mesos-agent-1)"

echo "---> killall and clean"
docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)

echo "---> start mesos slave"
docker run -d \
	-e MESOS_HOSTNAME=${SLAVE_IP} \
	-e MESOS_IP=${SLAVE_IP} \
	-e LIBPROCESS_IP=${SLAVE_IP} \
	-e MESOS_MASTER=zk://${ZK}/mesos \
	-e MESOS_LOG_DIR=/var/log/mesos \
	-e MESOS_LOGGING_LEVEL=INFO \
	-e MESOS_CONTAINERIZERS="docker,mesos" \
	-e MESOS_EXECUTOR_REGISTRATION_TIMEOUT="5mins" \
	-e MESOS_EXECUTOR_SHUTDOWN_GRACE_PERIO="90secs" \
	-e MESOS_DOCKER_STOP_TIMEOUT="60secs" \
	-e MESOS_PORT="5051" \
	-e MESOS_WORK_DIR=/tmp/mesos \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	-v /usr/bin/docker:/usr/bin/docker \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--name slave --net host --privileged --restart always \
	mesosphere/mesos-slave:1.0.0-2.0.89.ubuntu1404
