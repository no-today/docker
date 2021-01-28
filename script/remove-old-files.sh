#!/bin/bash

# 保留文件数
KEEP=3

FILE_DIR=$1

FILE_NUM=$(ls -1 $FILE_DIR/*.gz | wc -l)

while(( FILE_NUM > KEEP ))
do
  FILE=$(ls -rt  $FILE_DIR/*.gz | head -1)
  echo  "Delete file: " $FILE
  rm -f $FILE
  ((FILE_NUM--))
done