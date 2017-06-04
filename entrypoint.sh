#!/bin/dumb-init /bin/sh
set -xe

function init_db() {
  chown -R mysql:mysql /var/lib/mysql
  mysql_install_db --defaults-file=/etc/mysql/my.cnf --user=mysql
  mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql &
  sleep 10s
  mysql -u root --password="" <<-EOF
SET @@SESSION.SQL_LOG_BIN=0;
USE mysql;
DELETE FROM mysql.user ;
DROP USER IF EXISTS 'root'@'%','root'@'localhost','${MYSQL_USER}'@'localhost','${MYSQL_USER}'@'%';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}' ;
CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASS}' ;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION ;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION ;
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION ;
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'localhost' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOF
  killall mysqld
  killall mysqld_safe
  sleep 5s
  killall -9 mysqld || true
  killall -9 mysqld_safe || true
  sleep 5s
}

[ ! -f /var/lib/mysql/ibdata1 ] && {
  init_db
}

[ "$#" -gt 0 ] && {
  exec $@
}

mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql &
tail -f /var/lib/mysql/*.err
