#!/usr/bin/bash -x


echo "START CUSTOM SERVICE EXECUTION SCRIPT"
echo "START NGNIX"
/usr/sbin/nginx
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start NGX: $status"
  exit $status
fi

echo "START UWSGI"
uwsgi --ini /etc/nginx/uwsgi.ini  --daemonize ./uwsgi.log
if [ $status -ne 0 ]; then
  echo "Failed to start UWCGI: $status"
  exit $status
fi

echo "START SSHD"
/usr/sbin/sshd -p 22
echo "Status SSHD => "$?
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start SSHD: $status"
  exit $status
fi

while sleep 60; do
  echo "still running"
  ps aux |grep sshd |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep sshd |grep -q -v grep
  #ps aux |grep nginx |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done