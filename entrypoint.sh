#!/bin/dumb-init /bin/sh
set -e

function output() {
  echo -e "\033[0;36mentrypoint\033[0m $@"
}

function tail_db() {
  tail -f /var/lib/mysql/*.err | while read line; do
    echo -e "\033[0;32mmysql\033[0m $line"
  done
}

function wait_for_db() {
  local cur=0 max=30
  while [ ! -S /run/mysqld/mysqld.sock ]; do
    [[ $cur -ge $max ]] && {
      output "timed out waiting for socket"
      exit 1
    }
    output "waiting for mysql socket..."
    sleep 3
    let cur+=3
  done
  sleep 1
}

function stop_db() {
  local cur=0 max=10
  output "stopping db"
  killall mysqld
  killall mysqld_safe
  while (pgrep -f mysqld &> /dev/null); do
    [[ $cur -ge $max ]] && {
      output "timed out waiting for shutdown. forcefully killing db"
      killall -9 mysqld || true
      killall -9 mysqld_safe || true
      return
    }
    output "waiting for db shutdown..."
    sleep 1
    let cur+=1
  done
}

function init_db() {
  output "initializing database"
  chown -R mysql:mysql /var/lib/mysql
  mysql_install_db --defaults-file=/etc/mysql/my.cnf --user=mysql
  mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql &
  wait_for_db
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
  stop_db
}

[ ! -f /var/lib/mysql/ibdata1 ] && {
  init_db
}

[ "$#" -gt 0 ] && {
  exec $@
}

mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql &
tail_db
