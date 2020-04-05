#!/bin/bash
. ./port.sh

#
# -a 全部
# -i 包含
# -n 不包含(取反)
#

declare -A SERVER_NODE=()

# 服务:节点数量
SERVER_NODE['registry']=1
SERVER_NODE['gateway']=1

# 所有服务
SERVERS=(${!SERVER_NODE[@]})

# 需要运行的服务
RUN=()

# 校验是否有效(不能传入不存在的服务)
VALID=false

# 已经使用了的端口
USED_PORTS=()

while getopts "an:i:" arg
do
  case $arg in
	  # -a 运行全部服务
    a)
	    RUN="${SERVERS[@]}"
	    ;;
	  # -i 只需要运行(重启)传入的服务
	  i)
	    # 获取传入的服务参数
	    for SERVER in $*
	    do
		    VALID=false
		    # 过滤掉 -i 这个参数
		    if [ $SERVER != "-i" ]
		    then
		      # 取出参数逐个跟有效参数(SERVERS)比对,检测到无效参数直接结束,有效则加入 RUN。
		      for i in "${!SERVERS[@]}"
		      do
			      if [ $SERVER == ${SERVERS[i]} ]
			      then
   			      RUN="${RUN[@]} $SERVER"
			        VALID=true
			        continue
		    	  fi
		      done
		      if [ $VALID == false ]
		      then
			      echo "server ${SERVER} is invalid."
			      exit
		      fi
		    fi
 	    done
	    ;;
	  # -n 除了传入的服务,其他的都运行(重启)
	  n)
	    for i in "${!SERVERS[@]}"
	    do
		    VALID=false
		    for SERVER in $*
		    do
		      if [ $SERVER != "-n" ]
		      then
			      if [ $SERVER == ${SERVERS[i]} ]
			      then
			        VALID=true
			        continue
			      fi
		      fi
		    done
		    if [ $VALID == false ]
		    then
		      RUN="${RUN[@]} ${SERVERS[i]}"
		    fi
	    done
	  ;;
  esac
done

TEMP_RUN=($RUN)

for i in "${!TEMP_RUN[@]}"
do
  SERVER=${TEMP_RUN[${i}]}

  # 存在 jar 包才杀死重启
  if [ -f "${SERVER}.jar" ]
  then
	  PID=`ps -ef | grep ${SERVER}.jar | grep -v grep | awk '{print $2}'`
	  if [ 0 -ne ${#PID} ]
	  then
	    echo "kill ${SERVER}"
	    kill -9 $PID
	  fi

	  # 运行多节点
	  COUNTER=0
	  while(( $COUNTER < ${SERVER_NODE[${SERVER}]} ))
	  do
	    if [ $SERVER != "gateway" -a $SERVER != "registry" -a $SERVER != "rtm" ]
	    then
	      # 端口去重
	      while [ 1 ]; do
          PORT=`get_random_port 1 10000`

          USED=false
          TEMP_USED_PORTS=($USED_PORTS)
          for j in "${!TEMP_USED_PORTS[@]}"
          do
            if [ $PORT -eq ${TEMP_USED_PORTS[${j}]} ]
            then
              USED=true
            fi
          done

          if [ $USED == false ]
          then
            # 加入去重
            USED_PORTS="${USED_PORTS[@]} ${PORT}"
            break
          fi
        done

        # 日志目录
        if [ ! -d "log" ]
        then
          mkdir log
        fi

        nohup java -jar ${SERVER}.jar --server.port=${PORT} > log/${SERVER}.log 2>&1 &
        echo "start server ${SERVER}:${PORT} success."
	    else
        nohup java -jar ${SERVER}.jar > log/${SERVER}.log 2>&1 &
        echo "start server ${SERVER} success."
	    fi
	    let "COUNTER++"
    done

	  # 备份 jar 包
	  if [ ! -d "jar-backup/${SERVER}" ]
	  then
	    mkdir -p jar-backup/${SERVER}
	  fi
	  cp ${SERVER}.jar jar-backup/${SERVER}/${SERVER}-$(date +%Y-%m-%d-%H%M).jar
	fi
done

