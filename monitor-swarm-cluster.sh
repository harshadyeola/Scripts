#!/bin/bash
# In Crontab add following entry
# @reboot /bin/bash /root/bin/monitor-swarm.sh &
# Monitor Docker Swarm node Status
while true
do
  docker node ls | grep Down
  if [ $? == 0 ]; then
    CLUSTERSTATUS="$(docker node ls)"
	  echo "$CLUSTERSTATUS" | mail -s "$(hostname -f) " e2l9n1e5j7y5b0e6@shoppinpal.slack.com
  fi
  # add sleep time so that it does not burden the docker engine
  sleep 300
done
