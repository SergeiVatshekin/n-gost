FROM ubuntu:18.04

USER root

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get -y install sudo && apt-get -y install dialog apt-utils && apt-get -y install openssl && apt-get -y install libssl-dev && apt-get -y install libpcre3 libpcre3-dev && apt-get -y install zlib1g zlib1g-dev && apt-get -y install git && apt-get -y install gcc && apt-get -y install make

RUN mkdir /cprocsp-install
COPY csp/linux-amd64.tgz /cprocsp-install

RUN cd /cprocsp-install && tar zxvf linux-amd64.tgz && cd ./linux-amd64_deb && ./install.sh && dpkg -i ./cprocsp-rsa-* && dpkg -i ./cprocsp-cpopenssl-*

RUN mkdir /conf
COPY openssl/openssl.cnf /conf
RUN sed -i '/\[\s*new_oids\s*\]/e cat /conf/openssl.cnf' /etc/ssl/openssl.cnf

RUN mkdir /nginx-install
COPY nginx/nginx_conf.patch /nginx-install/

RUN cd /nginx-install && git clone https://github.com/nginx/nginx.git && cd ./nginx && git checkout branches/stable-1.16 && cp ../nginx_conf.patch ./ && git apply nginx_conf.patch

COPY openssl/config /opt/cprocsp/cp-openssl-1.1.0
RUN chmod +x /opt/cprocsp/cp-openssl-1.1.0/config

RUN cd /nginx-install/nginx && ./auto/configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --user=root --group=root --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-openssl=/opt/cprocsp/cp-openssl-1.1.0 && make && make install

RUN mkdir -p /var/cache/nginx/client_temp
RUN mkdir /var/cache/nginx/proxy_temp
RUN mkdir /var/cache/nginx/fastcgi_temp

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80/tcp
EXPOSE 443/tcp

ENTRYPOINT ["/start.sh"]

