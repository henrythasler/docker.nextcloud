FROM img-nginx:1.10.3-php7.0
MAINTAINER Henry Thasler <docker@thasler.org>

# Set correct environment variables; modify as needed
ENV WEBROOT /usr/share/nginx/html
ENV BUILDPATH /usr/src


# defines
ENV VERSION nextcloud-11.0.2
ENV SOURCE https://download.nextcloud.com/server/releases/
ENV GPGKEY nextcloud.asc
ENV GPGKEY_FINGERPRINT="2880 6A87 8AE4 23A2 8372  792E D758 99B9 A724 937A"
ENV GPGSOURCE https://nextcloud.com/

# prepare for installation of additional modules
RUN apt-get update
                
# install php7
RUN apt-get install -y --no-install-recommends \
                php7.0-xml \
                php7.0-mb \
                php7.0-zip \
                php7.0-bz2 \
                php7.0-imagick
                

# download files incl. signatures and key
RUN cd $WEBROOT \
        && wget $SOURCE$VERSION.tar.bz2 \
        && wget $SOURCE$VERSION.tar.bz2.asc \
        && wget $SOURCE$VERSION.tar.bz2.sha256 \
        && wget $GPGSOURCE$GPGKEY

# verify and extract archive file        
RUN cd $WEBROOT \
        && gpg --import $GPGKEY \
        && gpg --verify $VERSION.tar.bz2.asc \
        && tar -xjf $VERSION.tar.bz2

COPY nginx.conf /etc/nginx/sites-available/default

# modify php-fpm config
RUN     { \
        echo 'env[PATH] = /usr/local/bin:/usr/bin:/bin'; \
        echo 'php_admin_value[post_max_size] = 1G'; \
        echo 'php_admin_value[upload_max_filesize] = 1G'; \
        echo 'php_admin_value[max_execution_time] = 10800'; \
        echo 'php_admin_value[max_input_time] = 3600'; \
        echo 'php_admin_value[expose_php] = Off'; \
        echo 'php_admin_value[memory_limit] = 32M'; \
        } >> /etc/php/7.0/fpm/pool.d/www.conf 

COPY permissions.sh $BUILDPATH/permissions.sh
RUN $BUILDPATH/permissions.sh

# webserver root directory
WORKDIR $WEBROOT

# SSL-only
EXPOSE 443

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]