#!/bin/bash

# sh deploy-dev.sh -n pay       // 启动除了 pay 之外的微服务
# sh deploy-dev.sh -i pay appy  // 只启动 pay 和 apply 微服务

APPLICATIONS=(uaa gateway apply pay)
START=(nacos)
FLAT=false

while getopts "an:i:" arg
do
  case $arg in
    a)
      START="${START[@]} ${APPLICATIONS[@]}"
      ;;
    i)
      for param in $*
      do
        FLAT=false
        if [ $param != "-i" ]
        then
          for i in "${!APPLICATIONS[@]}"
          do
            if [ $param == ${APPLICATIONS[i]} ]
            then
              START="${START[@]} $param"
              FLAT=true
              continue
            fi
          done
          if [ $FLAT == false ]
          then
            echo "application: ${param} not found"
            exit
          fi
        fi
      done
      ;;
    n)
      for i in "${!APPLICATIONS[@]}"
      do
        FLAT=false
        for param in $*
        do
          if [ $param != "-n" ]
          then
            if [ $param == ${APPLICATIONS[i]} ]
            then
              FLAT=true
              continue
            fi
          fi
        done
        if [ $FLAT == false ]
        then
          START="${START[@]} ${APPLICATIONS[i]}"
        fi
      done
    ;;
  esac
done

echo "docker-compose up -d $START"
docker-compose -f ./microservice-all-dev.yml down
docker-compose -f ./microservice-all-dev.yml up -d $START
