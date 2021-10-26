#!/bin/bash
if [ $# = 0 ]; then
  echo "Usage: ./frame-system*.sh <start/stop/check> "
  exit 1
fi
start(){
      if [ -f " ./frame-system.pid"  ]; then
          echo "ERROR: App is running, please stop it first. [erathink.sh stop]"
          exit 1
      fi
   ET_HOME=`pwd`

    export ET_HOME=$ET_HOME
    nohup java -Dfastjson.parser.autoTypeSupport=true \
               -Xms128m -Xmx3g -XX:+UseG1GC -jar eladmin-system*.jar \
		       -Dspring.config.location="file://$ET_HOME/config/application.yml" \
		       --spring.profiles.active=dev \
    >app_running.log 2>&1 & \
    echo $! > ./frame-system.pid &
    echo "INFO: Application started, logs in $ET_HOME/app_running.log"
    exit 0
}

stop(){
	ET_HOME=`pwd`
	 if [ ! -f "./frame-system.pid" ]
	    then
	        echo "ERROR: Application is not running, please check"
	        exit 0
	    fi
	    pid=`cat ./frame-system.pid`
	    if [ "$pid" = "" ]
	    then
	        echo "ERROR: Application is not running"
			rm -rf ./frame-system.pid
	        exit 0
	    else
	        echo "INFO: Stopping application: $pid"
	        rm -rf ./frame-system.pid
	        kill -9 $pid
	    fi
	    exit 0
}

check(){
	cd ${bin}/..
	ET_HOME=`pwd`
        mytime=$(date "+%Y-%m-%d %H:%M:%S")
	 if [ ! -f "./frame-system.pid" ]
	 then
	   echo "$mytime ERROR: Application is not running"
	   exit 0
	 fi
	 pid=`cat ./frame-system.pid`
	 if [ "$pid" = "" ]
	 then
	   echo "$mytime ERROR: Application is not running"
	   rm -rf ./frame-system.pid
	   exit 0
	 fi
         ps_out=`ps -ef | grep $pid | grep -v 'grep'`
         result=$(echo $ps_out | grep "$1")
         if [[ "$result" != "" ]];then
            echo "$mytime CHECKED: Application is running: $pid"
         else
            echo "$mytime DEAD, Restarting NOW!"
            stop
            start
         fi
	 exit 0
}