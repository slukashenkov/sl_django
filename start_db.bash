#!/usr/bin/bash -x


echo "START CUSTOM SERVICE EXECUTION SCRIPT"
echo "START SSHD"
/usr/sbin/sshd -p 22
echo "Status SSHD => "$?
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start SSHD: $status"
  exit $status
fi


echo "START POSTGRESQL"
#su postgres -c "/usr/pgsql-11/bin/pg_ctl start -D /var/lib/pgsql/11/data/"
#status=$?
#if [ $status -ne 0 ]; then
#  echo "Failed to start Postgres: $status"
#  exit $status
#fi

USER="slon_20"
DB_NAME="sl_web_20"
su postgres -c "psql -c \"create user ${USER}  with encrypted  password 'abc123'\""
su postgres -c "psql -c \"create database ${DB_NAME}\""
su postgres -c "psql -c \"grant all privileges on database ${DB_NAME} to ${USER}\""



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