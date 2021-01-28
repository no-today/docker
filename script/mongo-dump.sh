#!/bin/bash

# 容器名
CONTAINER_NAME=$1

# 用户名 & 密码
USERNAME=$2
PASSWORD=$3

# 宿主机备份文件存放路径
BACKUP_PATH=$4

# 备份时间标记
ARCHIVE_FILE_NAME="$(date +%Y%m%d%H%M%S).gz"

echo "开始备份: $CONTAINER_NAME $ARCHIVE_FILE_NAME"

docker exec $CONTAINER_NAME mongodump --archive=$ARCHIVE_FILE_NAME --gzip --uri=mongodb://${USERNAME}:${PASSWORD}@localhost:27017
docker cp $CONTAINER_NAME:$ARCHIVE_FILE_NAME $BACKUP_PATH/$ARCHIVE_FILE_NAME
docker exec $CONTAINER_NAME rm $ARCHIVE_FILE_NAME

echo "执行完成: $CONTAINER_NAME $ARCHIVE_FILE_NAME"

# 删除旧备份

# 保留备份数
KEEP=3

FILE_DIR=$BACKUP_PATH

FILE_NUM=$(ls -1 $FILE_DIR/*.gz | wc -l)

while(( FILE_NUM > KEEP ))
do
  FILE=$(ls -rt  $FILE_DIR/*.gz | head -1)
  echo  "Delete file: " $FILE
  rm -f $FILE
  ((FILE_NUM--))
done