#This script contains the run commands for both the normal web and dbserver
#and for the stripped web and dbserver

#dbserver run command (explanation of different lines in the README)
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
  -e MYSQL_ROOT_PASSWORD="RubbishPassWord" \
  -e MYSQL_DATABASE="csvsdb" \
  --cap-drop=ALL \
  --cap-add=SETGID --cap-add=SETUID --cap-add=CHOWN \
  --read-only \
  --security-opt label:type:docker_dbserver_t \
  --security-opt seccomp:docker_dbserver.json \
  --name u123_csvs2020-db_c \
  u123/csvs2020-db_i

#replace u123/csvs2020-db_i  with  u123/csvs2020-db_i_stripped

#webserver run command (explanation of different lines in the README)
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
  --add-host db.cyber.test:198.51.100.3 \
  -p 3333:80 \
  --cap-drop=ALL \
  --cap-add=CHOWN --cap-add=SETGID --cap-add=SETUID --cap-add=NET_BIND_SERVICE \
  --read-only \
  --security-opt label:type:docker_webserver_t \
  --security-opt seccomp:docker_webserver.json \
  --name u123_csvs2020-web_c \
  u123/csvs2020-web_i

#replace u123/csvs2020-web_i  with  u123/csvs2020-web_i_stripped

