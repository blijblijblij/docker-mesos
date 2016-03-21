#!/bin/sh

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
MESOS_MASTER_1=$(docker-machine ip mesos-m1)
MESOS_MASTER_2=$(docker-machine ip mesos-m2)
MESOS_MASTER_3=$(docker-machine ip mesos-m3)
SLAVE_IP=$(docker-machine ip mesos-s1)
ZK=${MESOS_MASTER_1}:2181,${MESOS_MASTER_2}:2181,${MESOS_MASTER_3}:2181

echo "start mesos-s1" | figlet | lolcat
docker-machine env mesos-s1
eval "$(docker-machine env mesos-s1)"
docker rm -f slave

echo "---> start mesos slave" | lolcat
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MESOS_HOSTNAME=${SLAVE_IP} \
	-e MESOS_IP=${SLAVE_IP} \
	-e MESOS_MASTER=zk://${ZK}/mesos \
	-e MESOS_LOG_DIR=/var/log/mesos \
	-e MESOS_LOGGING_LEVEL=INFO \
	-e MESOS_CONTAINERIZERS="docker,mesos" \
	-e MESOS_EXECUTOR_REGISTRATION_TIMEOUT="5mins" \
	-e MESOS_EXECUTOR_SHUTDOWN_GRACE_PERIO="90secs" \
	-e MESOS_DOCKER_STOP_TIMEOUT="60secs" \
	-e MESOS_PORT="5051" \
	-v /sys:/sys \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /cgroup:/cgroup \
	-v /usr/local/bin/docker:/usr/bin/docker \
	--name slave --net host --privileged --restart always \
	mesosphere/mesos-slave:0.26.0-0.2.145.ubuntu1404
