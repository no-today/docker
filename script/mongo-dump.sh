#!/bin/bash

# 容器名
CONTAINER_NAME=$1

# 用户名 & 密码
USERNAME=$2
PASSWORD=$3

# 宿主机备份目录
BACKUP_PATH=$4

docker exec $CONTAINER_NAME mongodump -h 127.0.0.1 --port 27017 -u=$USERNAME -p=$PASSWORD -o /dump
docker cp $CONTAINER_NAME:/dump $BACKUP_PATH
