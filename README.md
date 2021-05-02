# harden-nginx-mariadb

**Docker Network**
---

```
docker network create --subnet=198.51.100.0/24 u123/csvs2020_n
```

**DATABASE (MariaDB)**

The build command for the dbserver
---

```
docker build -t u123/csvs2020-db_i .
```

###The run command for the dbserver
### 1. uses the network with the name u123/csvs2020_n
### 2. uses cgroup commands to limit memory and defines a particular cpu core
### 3. uses temporary file system mounts that need to be writable in order to have a functioning read-	 only container
###4. mounts a DBSERVER_VOLUME (made it read-only for enhanced security)
###5. drops all existing caps and adds only the necessary ones
###6. adds the security-opts for SELinux and SECCOMP

```
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
```

###only necessary for stracing
```
-v $PWD/output_h:/output_c:rw \
```

###stripping
```
u123/csvs2020-db_i_stripped
```

###dropping all caps and adding specific ones is (kind of) equal to:
```
--cap-drop=DAC_OVERRIDE --cap-drop=FOWNER --cap-drop=FSETID --cap-drop=KILL --cap-drop=SETPCAP --cap-drop=NET_BIND_SERVICE --cap-drop=NET_RAW --cap-drop=SYS_CHROOT --cap-drop=MKNOD --cap-drop=AUDIT_WRITE --cap-drop=SETFCAP \
```

###the following capability was only used during the stracing process
```
--cap-add=SYS_PTRACE
```

###Run this command to execute the dbserver
```
docker exec -i u123_csvs2020-db_c mysql -uroot -pRubbishPassWord < sqlconfig/csvsdb.sql
```
###use the following command to interact with mariadb in the shell
```
docker exec -it u123_csvs2020-db_c mysql -uroot -pRubbishPassWord
```

###This will create a pre-configured database which can be used by the web application.

**WEBSERVER (nginx)**

###After building the NGINX dockerfile you can use the following run-time command to get started:

###The run command for the webserver
### 1. uses the network with the name u123/csvs2020_n
### 2. uses cgroup commands to limit memory and defines a particular cpu core
### 3. uses temporary file system mounts that need to be writable in order to have a functioning read-	 only container
###4. mounts a DBSERVER_VOLUME (made it read-only for enhanced security)
###5. maps the port 80 to the port 3333 on the host
###6. drops all existing caps and adds only the necessary ones
###7. adds the security-opts for SELinux and SECCOMP

```
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
```

###only necessary for stracing
```
-v $PWD/output_h:/output_c:rw \
```

###stripping
```
u123/csvs2020-web_i_stripped
```

###dropping all caps and adding specific ones is (kind of) equal to:
```
--cap-drop=DAC_OVERRIDE --cap-drop=FOWNER --cap-drop=FSETID --cap-drop=KILL --cap-drop=SETPCAP --cap-drop=NET_RAW --cap-drop=SYS_CHROOT --cap-drop=MKNOD --cap-drop=AUDIT_WRITE --cap-drop=SETFCAP \
```

###the following capability was only used during the stracing process
```
--cap-add=SYS_PTRACE
```

**Stracing**

###in the run command:
```
--cap-add=SYS_PTRACE
```

###docker inspect container_name gives the entrypoint pid which can be straced
###PROBLEM: initial system calls are  missing

###host command to strace the correct process ID and delay the inspection
```
sudo strace -p $(docker inspect -f '{{.State.Pid}}' u123_csvs2020-web_c) -o output_h/strace_host_output -ff &
```

```
sudo strace -p $(docker inspect -f '{{.State.Pid}}' u123_csvs2020-db_c) -o output_h/strace_host_output -ff &
```

###in another terminal
```
touch output_h/ready
```

###grep out the system calls and remove duplicates
```
cat strace_host_output.* | grep -o "^[^(]*" | sort -u
```

###add to the policy
###then add new security-opt to the run commands
```
--security-opt seccomp:docker_webserver.json
--security-opt seccomp:docker_dbserver.json
```

###and then remove this capability:
```
--cap-add=SYS_PTRACE
```

# http://localhost/ to view the web application!

