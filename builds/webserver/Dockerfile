# NGINX Dockerfile

FROM centos:7

RUN 	yum install epel-release -y && \
	yum update -y && \
	yum install -y \
	nginx \
	php \
	php-mysql \
	php-fpm 
	

COPY configfiles/nginx.conf /etc/nginx/nginx.conf
COPY configfiles/php.ini /etc/php.ini
COPY configfiles/www.conf /etc/php-fpm.d/www.conf
USER apache
COPY webfiles/ /usr/share/nginx/html
USER root
COPY configfiles/docker-entrypoint.sh /

RUN rm -f /usr/share/nginx/html/index.html /usr/share/nginx/html/nginx-logo.png /usr/share/nginx/html/poweredby.png
RUN chmod +x /docker-entrypoint.sh

# I also changed the PORT Mapping to 3333. If I needed to launch multiple webserver containers,
# the container would fail to run since the port 80 is already in use (Raj et al., 2016).
EXPOSE 3333

VOLUME /var/log/webserver/

ENTRYPOINT ["/docker-entrypoint.sh"]
