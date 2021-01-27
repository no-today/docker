#!/bin/bash

# 容器名
CONTAINER_NAME=$1

# 用户名 & 密码
USERNAME=$2
PASSWORD=$3

# 宿主机备份目录
BACKUP_PATH=$4

echo " 开始恢复: $CONTAINER_NAME $(date +%Y-%m-%d_%H:%M:%S)"

docker cp $BACKUP_PATH $CONTAINER_NAME:/restore
docker exec $CONTAINER_NAME mongorestore --host 127.0.0.1 --port 27017 -u $USERNAME -p=$PASSWORD --authenticationDatabase admin /restore
docker exec $CONTAINER_NAME rm -rf /restore

echo " 执行完成: $CONTAINER_NAME $(date +%Y-%m-%d_%H:%M:%S)"