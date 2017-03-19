FROM img-nginx:1.10.3-php7.0
MAINTAINER Henry Thasler <docker@thasler.org>

# Set correct environment variables; modify as needed
ENV WEBROOT /usr/share/nginx/html
ENV BUILDPATH /usr/src
ENV SERVER_NAME www.thasler.com
ENV CERT www_thasler_com.pem
ENV KEY www_thasler_com.key

# defines
ENV VERSION nextcloud-11.0.2
ENV SOURCE https://download.nextcloud.com/server/releases/
ENV GPGKEY nextcloud.asc
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
        && wget $GPGSOURCE$GPGKEY

# verify and extract archive file        
RUN cd $WEBROOT \
        && gpg --import $GPGKEY \
        && gpg --verify $VERSION.tar.bz2.asc \
        && tar -xjf $VERSION.tar.bz2

COPY nextcloud.conf /etc/nginx/sites-available/default

COPY permissions.sh $BUILDPATH/permissions.sh
RUN $BUILDPATH/permissions.sh

# webserver root directory
WORKDIR $WEBROOT

# SSL-only
EXPOSE 443