#/bin/bash
#
# Set up the mysql database with tables and users
#

set -eu
set -o pipefail

echo "init mysql admin user"
mysql_install_db
mysqld_safe &
# TODO: replace sleep with polling
sleep 10s

echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'admin' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

pkill -f mysqld
