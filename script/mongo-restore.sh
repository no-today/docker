#!/bin/bash

# 容器名
CONTAINER_NAME=$1

# 用户名 & 密码
USERNAME=$2
PASSWORD=$3

# 宿主机恢复文件存放路径
ARCHIVE_FILE_PATH=$4

echo "开始恢复: $CONTAINER_NAME $ARCHIVE_FILE_PATH"

docker cp $ARCHIVE_FILE_PATH $CONTAINER_NAME:restore.gz
docker exec $CONTAINER_NAME mongorestore --gzip --archive=restore.gz --uri=mongodb://${USERNAME}:${PASSWORD}@localhost:27017
docker exec $CONTAINER_NAME rm -rf /restore

echo "执行完成: $CONTAINER_NAME $ARCHIVE_FILE_PATH"