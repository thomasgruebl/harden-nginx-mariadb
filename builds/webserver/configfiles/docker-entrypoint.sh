#!/bin/bash

#adding the while loop in order to check the existence of the ready file
#only if the file exists, the nginx server is started
#which helps me not to lose any important system calls

#while [ ! -f /output_c/ready ]
#do
#	sleep 5
#done

/usr/sbin/nginx
/usr/sbin/php-fpm -F
