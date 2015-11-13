#/bin/bash
#
# Set up the mysql database with tables and users
#
mysqld_safe &
sleep 10s
/opt/phabricator/bin/config set mysql.host 127.0.0.1
/opt/phabricator/bin/config set mysql.user admin
/opt/phabricator/bin/config set mysql.pass admin
/opt/phabricator/bin/storage upgrade --force
