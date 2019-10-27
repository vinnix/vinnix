#!/usr/bin/ksh

HOME_DIR=/host/linux_dev
LOG_DIR=${HOME_DIR}/logs

export HOME_DIR
export LOG_DIR

#
# Cleanup old files
#
rm ${LOG_DIR}/*

echo PARENTPID=$$ > ${LOG_DIR}/allPids.txt

total_children=3
sleep_before_start=1
sleep_check_interval=2

echo Starting ${total_children} children
i=0
while [[ $i -lt ${total_children} ]]
do
  sleep $sleep_before_start
  child $i >> ${LOG_DIR}/child_log_$i.txt 2>&1 &
  i=$((i+1))
done

sleep $sleep_before_start

. ${LOG_DIR}/allPids.txt

echo Children started, checking on them
while [[ $i -lt 1000 ]]
do
  sleep $sleep_check_interval
  j=0
  while [[ $j -lt ${total_children} ]]
  do
    . ${LOG_DIR}/CHILD_${j}_STATE
    if [[ ${CHILDSTATE} == 'DONE' ]]
    then
      echo CHILD $i is DONE
    elif [[ ${CHILDSTATE} == 'SUCCESS' ]]
    then
      eval "CHILDINSTANCEVAR=CHILD_${j}_PID"
      eval "CHILDINSTANCEPID=\$$CHILDINSTANCEVAR"
      echo "Checking CHILDINSTANCEPID=${CHILDINSTANCEPID}"
      CHILDINSTANCES=`ps auxwww | grep ${CHILDINSTANCEPID} | grep -v grep | wc -l`
      if [[ ${CHILDINSTANCES} -lt 1 ]]
      then
        echo "CHILD $j IS NOT DONE, BUT NOT RUNNING, Exiting"
        exit 1
      else
        echo "CHILD $j is running fine"
      fi
    else
      echo "CHILD $j needs attention, Exiting"
    fi
    j=$((j+1))
  done

  i=$((i+1))
done
