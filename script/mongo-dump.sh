#!/bin/bash

# 容器名
CONTAINER_NAME=$1

# 用户名 & 密码
USERNAME=$2
PASSWORD=$3

# 宿主机备份文件存放路径
BACKUP_PATH=$4

# 备份时间标记
ARCHIVE_FILE_NAME="$(date +%Y%m%d%H).gz"

echo "开始备份: $CONTAINER_NAME $ARCHIVE_FILE_NAME"

docker exec $CONTAINER_NAME mongodump --archive=$ARCHIVE_FILE_NAME --gzip --uri=mongodb://${USERNAME}:${PASSWORD}@localhost:27017
docker cp $CONTAINER_NAME:$ARCHIVE_FILE_NAME $BACKUP_PATH/$ARCHIVE_FILE_NAME
docker exec $CONTAINER_NAME rm $ARCHIVE_FILE_NAME

echo "执行完成: $CONTAINER_NAME $ARCHIVE_FILE_NAME"