#!/bin/bash

# mysqldump所在路径
MYSQLDUMP_PATH=/usr/bin/mysqldump

# 容器ID
CONTINER_ID=$1
# 备份的库
DATABASE=$2
# 保留3个备份集
SKIP=3

# 备份文件保存路径
BACKUP_PATH=/data/mysql/_backup/$DATABASE
DATETIME=$(date +%Y_%m_%d_%H%M%S)

echo "--------------------备份数据库[$DATABASE]-------------------"
echo " start datetime: $(date +%Y-%m-%d_%H:%M:%S)"

# 文件夹不存在则创建
if [ ! -e "$BACKUP_PATH/$DATETIME" ]
then
	mkdir -p "$BACKUP_PATH/$DATETIME"
fi

# 备份
docker exec $CONTINER_ID $MYSQLDUMP_PATH --defaults-file=/etc/mysql/conf.d/my.cnf $DATABASE | gzip > $BACKUP_PATH/$DATETIME/$DATETIME.sql.gz

# 打包
cd $BACKUP_PATH
tar -zcvf $DATETIME.tar.gz $DATETIME

# 删除临时目录
rm -rf $BACKUP_PATH/$DATETIME

# 保留备份集(最新)
# ls获取不到length,所以先将ls的文件转成数组
INDEX=0
for file in `ls $BACKUP_PATH`
do
	FILE_LIST[$INDEX]="$file"
	((INDEX++))
done

for i in "${!FILE_LIST[@]}"
do
	if [ $i -ge $[${#FILE_LIST[*]} - $SKIP] ]
	then
		break
	else
		rm ${FILE_LIST[$i]}
	fi
	((INDEX++))
done
		
echo "   end datetime: $(date +%Y-%m-%d_%H:%M:%S)"
echo "--------------------数据库备份完成--------------------------"
