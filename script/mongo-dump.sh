#!/bin/bash

# 容器名
CONTAINER_NAME=$1

# 用户名 & 密码
USERNAME=$2
PASSWORD=$3

# 宿主机备份目录
BACKUP_PATH=$4

# 备份时间标记
DATETIME=$(date +%Y-%m-%d_%H:%M:%S)

echo " 开始备份: $CONTAINER_NAME $(date +%Y-%m-%d_%H:%M:%S)"

docker exec $CONTAINER_NAME mongodump --host 127.0.0.1 --port 27017 -u $USERNAME -p $PASSWORD --authenticationDatabase admin -o /dump/$DATETIME
docker cp $CONTAINER_NAME:/dump/$DATETIME $BACKUP_PATH/$DATETIME
docker exec $CONTAINER_NAME rm -rf /dump/$DATETIME

echo " 执行完成: $CONTAINER_NAME $(date +%Y-%m-%d_%H:%M:%S)"