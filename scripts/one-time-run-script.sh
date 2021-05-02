#This script contains the run commands that are only run once
#such as the volume mounting for the stracing

#for the webserver-stripped and dbserver-stripped:
#execute ./strip-cmd in the directory

#run this command to execute the dbserver
#docker exec -i u123_csvs2020-db_c mysql -uroot -pRubbishPassWord < sqlconfig/csvsdb.sql

#webserver run command with    (explanation of different lines in the README)
# 1. one time volume for stracing
# 2. one time --cap-add=SYS_PTRACE

docker run -d \
  --net u123/csvs2020_n \
  --ip 198.51.100.10 \
  --hostname www.cyber.test \
  --memory="100m" \
  --memory-swap="300m" \
  --cpuset-cpus=0 \
  --tmpfs /var/log/nginx \
  --tmpfs /var/lib/nginx/tmp \
  --tmpfs /var/log/php-fpm \
  --tmpfs /var/run/php-fpm \
  --tmpfs /run \
  -v WEBSERVER_VOLUME:/var/log/webserver/:ro \
  -v $PWD/output_h:/output_c:rw \
  --add-host db.cyber.test:198.51.100.3 \
  -p 3333:80 \
  --cap-drop=ALL \
  --cap-add=CHOWN --cap-add=SETGID --cap-add=SETUID --cap-add=NET_BIND_SERVICE --cap-add=SYS_PTRACE \
  --read-only \
  --security-opt label:type:docker_webserver_t \
  --security-opt seccomp:docker_webserver.json \
  --name u123_csvs2020-web_c \
  u123/csvs2020-web_i

#dbserver run command with    (explanation of different lines in the README)
# 1. one time volume for stracing
# 2. one time --cap-add=SYS_PTRACE

docker run -d \
  --net u123/csvs2020_n \
  --ip 198.51.100.3 \
  --hostname db.cyber.test \
  --memory="300m" \
  --memory-swap="1g" \
  --cpuset-cpus=0 \
  --tmpfs /tmp \
  --tmpfs /var/run/mysqld \
  --tmpfs /var/lib/mysqld \
  --tmpfs /run/mysqld \
  --tmpfs /var \
  -v DBSERVER_VOLUME:/var/log/dbserver/:ro \
  -v $PWD/output_h:/output_c:rw \
  -e MYSQL_ROOT_PASSWORD="RubbishPassWord" \
  -e MYSQL_DATABASE="csvsdb" \
  --cap-drop=ALL \
  --cap-add=SETGID --cap-add=SETUID --cap-add=CHOWN --cap-add=SYS_PTRACE \
  --read-only \
  --security-opt label:type:docker_dbserver_t \
  --security-opt seccomp:docker_dbserver.json \
  --name u123_csvs2020-db_c \
  u123/csvs2020-db_i
