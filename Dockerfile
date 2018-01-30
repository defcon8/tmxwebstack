FROM debian:8
LABEL description="Complete secured server stack for TMX-Web"
LABEL author="b.j.dewaard@tmx.nl"

ENV PHP_VERSION 7.1

# Start bootstrapping..
RUN apt-get update
RUN apt-get install -y wget curl apt-transport-https unzip lsb-release ca-certificates

# Add dotdeb to APT sources list
RUN echo 'deb http://packages.dotdeb.org jessie all' > /etc/apt/sources.list.d/dotdeb.list
RUN curl http://www.dotdeb.org/dotdeb.gpg | apt-key add -

# Add PHP repository to APT sources list
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo 'deb https://packages.sury.org/php/ jessie main' > /etc/apt/sources.list.d/php.list

RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get install -y php$PHP_VERSION php$PHP_VERSION-fpm php$PHP_VERSION-curl php$PHP_VERSION-bz2 php$PHP_VERSION-gd php$PHP_VERSION-mbstring php$PHP_VERSION-mcrypt php$PHP_VERSION-json php$PHP_VERSION-intl php$PHP_VERSION-xml php$PHP_VERSION-xsl php$PHP_VERSION-simplexml php$PHP_VERSION-zip
RUN apt-get mono-complete

#  Configure PHP
RUN ["bin/bash", "-c", "sed -i 's/max_execution_time\\s*=.*/max_execution_time=180/g' /etc/php/$PHP_VERSION/fpm/php.ini"]
RUN ["bin/bash", "-c", "sed -i 's/upload_max_filesize\\s*=.*/upload_max_filesize=16M/g' /etc/php/$PHP_VERSION/fpm/php.ini"]
RUN ["bin/bash", "-c", "sed -i 's/post_max_size\\s*=.*/post_max_size=16M/g' /etc/php/$PHP_VERSION/fpm/php.ini"]

# Install IONCube loader
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
RUN tar xvfz ioncube_loaders_lin_x86-64.tar.gz
RUN ["bin/bash", "-c", "cp ioncube/*.so /usr/lib/php/2*/"]
RUN ["bin/bash", "-c", "cd /etc/php/$PHP_VERSION/fpm/conf.d && echo zend_extension = /usr/lib/php/2*/ioncube_loader_lin_$PHP_VERSION.so > 00-ioncube.ini"]

# NGINX Configuration
# Remove the default NGINX virtualhost & symbolic link
RUN rm -v /etc/nginx/sites-enabled/default
RUN rm -v /etc/nginx/sites-available/default
# Add our custom virtualhost
ADD nginx/virtualhost.conf /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# FPM Configuration
RUN rm -v /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
ADD fpm/tmx.conf /etc/php/$PHP_VERSION/fpm/pool.d/tmx.conf

# Expose ports
EXPOSE 80

# Mount path as volume to allow user to inject the TMX-Web code
VOLUME ["/jail/var/tmxweb"]

# Create entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]