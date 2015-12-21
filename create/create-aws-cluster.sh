#!/bin/sh
clear

# generic config
# AWS_ACCESS_KEY="..."
# AWS_SECRET_KEY="..."
AWS_ROOT_SIZE="50"

# eu-west-1
AWS_AMI="ami-823686f5"
AWS_DEFAULT_REGION="eu-west-1"

# this depend on your aws environment
AWS_VPC_ID="vpc-be5dfbdb"
AWS_SUBNET_ID_A="subnet-b2b00ac5"
AWS_SUBNET_ID_B="subnet-d9b76880"
AWS_SUBNET_ID_C="subnet-6b00920e"

clean() {
  echo "---> rm old machines" | lolcat
  docker-machine rm -f mesos-m1 mesos-m2 mesos-m3 mesos-s1 mesos-s2 mesos-s3 > /dev/null
}

create_masters() {
echo "---> create masters" | lolcat
echo "---> create mesos-m1" | lolcat
docker-machine create \
  --driver amazonec2 \
  --amazonec2-access-key $AWS_ACCESS_KEY \
  --amazonec2-ami $AWS_AMI \
  --amazonec2-instance-type "t2.micro" \
  --amazonec2-root-size $AWS_ROOT_SIZE \
  --amazonec2-region $AWS_DEFAULT_REGION \
  --amazonec2-secret-key $AWS_SECRET_KEY \
  --amazonec2-subnet-id $AWS_SUBNET_ID_A \
  --amazonec2-vpc-id $AWS_VPC_ID \
  --amazonec2-zone "a" \
  --amazonec2-security-group "mesos-master" \
  mesos-m1

echo "---> create mesos-m2" | lolcat
docker-machine create \
  --driver amazonec2 \
  --amazonec2-access-key $AWS_ACCESS_KEY \
  --amazonec2-ami $AWS_AMI \
  --amazonec2-instance-type "t2.micro" \
  --amazonec2-root-size $AWS_ROOT_SIZE \
  --amazonec2-region $AWS_DEFAULT_REGION \
  --amazonec2-secret-key $AWS_SECRET_KEY \
  --amazonec2-subnet-id $AWS_SUBNET_ID_B \
  --amazonec2-vpc-id $AWS_VPC_ID \
  --amazonec2-zone "b" \
  --amazonec2-security-group "mesos-master" \
  mesos-m2

echo "---> create mesos-m3" | lolcat
docker-machine create \
  --driver amazonec2 \
  --amazonec2-access-key $AWS_ACCESS_KEY \
  --amazonec2-ami $AWS_AMI \
  --amazonec2-instance-type "t2.micro" \
  --amazonec2-root-size $AWS_ROOT_SIZE \
  --amazonec2-region $AWS_DEFAULT_REGION \
  --amazonec2-secret-key $AWS_SECRET_KEY \
  --amazonec2-subnet-id $AWS_SUBNET_ID_C \
  --amazonec2-vpc-id $AWS_VPC_ID \
  --amazonec2-zone "c" \
  --amazonec2-security-group "mesos-master" \
  mesos-m3
}

create_slaves() {
echo "---> create mesos-s1" | lolcat
docker-machine create \
    --driver amazonec2 \
    --amazonec2-access-key $AWS_ACCESS_KEY \
    --amazonec2-ami $AWS_AMI \
    --amazonec2-instance-type "m4.xlarge" \
    --amazonec2-root-size $AWS_ROOT_SIZE \
    --amazonec2-region $AWS_DEFAULT_REGION \
    --amazonec2-secret-key $AWS_SECRET_KEY \
    --amazonec2-subnet-id $AWS_SUBNET_ID_A \
    --amazonec2-vpc-id $AWS_VPC_ID \
    --amazonec2-zone "a" \
    --amazonec2-security-group "mesos-slave" \
    mesos-s1

echo "---> create mesos-s2" | lolcat
docker-machine create \
    --driver amazonec2 \
    --amazonec2-access-key $AWS_ACCESS_KEY \
    --amazonec2-ami $AWS_AMI \
    --amazonec2-instance-type "m4.xlarge" \
    --amazonec2-root-size $AWS_ROOT_SIZE \
    --amazonec2-region $AWS_DEFAULT_REGION \
    --amazonec2-secret-key $AWS_SECRET_KEY \
    --amazonec2-subnet-id $AWS_SUBNET_ID_B \
    --amazonec2-vpc-id $AWS_VPC_ID \
    --amazonec2-zone "b" \
    --amazonec2-security-group "mesos-slave" \
    mesos-s2

echo "---> create mesos-s3" | lolcat
docker-machine create \
    --driver amazonec2 \
    --amazonec2-access-key $AWS_ACCESS_KEY \
    --amazonec2-ami $AWS_AMI \
    --amazonec2-instance-type "m4.xlarge" \
    --amazonec2-root-size $AWS_ROOT_SIZE \
    --amazonec2-region $AWS_DEFAULT_REGION \
    --amazonec2-secret-key $AWS_SECRET_KEY \
    --amazonec2-subnet-id $AWS_SUBNET_ID_C \
    --amazonec2-vpc-id $AWS_VPC_ID \
    --amazonec2-zone "c" \
    --amazonec2-security-group "mesos-slave" \
    mesos-s3
}

create_spot_instance_slaves() {

echo "---> create mesos-s4" | lolcat
docker-machine create \
    --driver amazonec2 \
    --amazonec2-access-key $AWS_ACCESS_KEY \
    --amazonec2-ami $AWS_AMI \
    --amazonec2-instance-type "m4.xlarge" \
    --amazonec2-root-size $AWS_ROOT_SIZE \
    --amazonec2-region $AWS_DEFAULT_REGION \
    --amazonec2-secret-key $AWS_SECRET_KEY \
    --amazonec2-subnet-id $AWS_SUBNET_ID_A \
    --amazonec2-vpc-id $AWS_VPC_ID \
    --amazonec2-zone "a" \
    --amazonec2-request-spot-instance \
    --amazonec2-spot-price "0.05" \
    --amazonec2-security-group "mesos-slave" \
    mesos-s-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)

echo "---> create mesos-s5" | lolcat
docker-machine create \
    --driver amazonec2 \
    --amazonec2-access-key $AWS_ACCESS_KEY \
    --amazonec2-ami $AWS_AMI \
    --amazonec2-instance-type "m4.xlarge" \
    --amazonec2-root-size $AWS_ROOT_SIZE \
    --amazonec2-region $AWS_DEFAULT_REGION \
    --amazonec2-secret-key $AWS_SECRET_KEY \
    --amazonec2-subnet-id $AWS_SUBNET_ID_B \
    --amazonec2-vpc-id $AWS_VPC_ID \
    --amazonec2-zone "b" \
    --amazonec2-request-spot-instance \
    --amazonec2-spot-price "0.07" \
    --amazonec2-security-group "mesos-slave" \
    mesos-s-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)

echo "---> create mesos-s6" | lolcat
docker-machine create \
    --driver amazonec2 \
    --amazonec2-access-key $AWS_ACCESS_KEY \
    --amazonec2-ami $AWS_AMI \
    --amazonec2-instance-type "m4.xlarge" \
    --amazonec2-root-size $AWS_ROOT_SIZE \
    --amazonec2-region $AWS_DEFAULT_REGION \
    --amazonec2-secret-key $AWS_SECRET_KEY \
    --amazonec2-subnet-id $AWS_SUBNET_ID_C \
    --amazonec2-vpc-id $AWS_VPC_ID \
    --amazonec2-zone "c" \
    --amazonec2-request-spot-instance \
    --amazonec2-spot-price 0.05 \
    --amazonec2-security-group "mesos-slave" \
    mesos-s-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
}

main() {
  echo "aws cluster" | figlet | lolcat
  clean
  create_masters
  create_slaves
  create_spot_instance_slaves
  echo "done" | figlet | lolcat
}

main
