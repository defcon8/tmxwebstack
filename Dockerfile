FROM debian:8

RUN apt-get update
RUN apt-get install -y wget curl apt-transport-https unzip

# Add dotdeb to APT sources list
RUN echo 'deb http://packages.dotdeb.org jessie all' > /etc/apt/sources.list.d/dotdeb.list
RUN curl http://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update

RUN apt-get install -y naxsi
RUN apt-get install -y php7.0 php7.0-curl php7.0-gd php7.0-mbstring php7.0-imagick php7.0-mysql php7.0-simplexml php7.0-zip

# Configure NGINX
#RUN ["bin/bash", "-c", "sed -i 's/AllowOverride None/AllowOverride All\\nSetEnvIf X-Forwarded-Proto https HTTPS=on/g' /etc/apache2/apache2.conf"]

# RUN service NGINX restart

# Configure PHP
# RUN ["bin/bash", "-c", "sed -i 's/max_execution_time\\s*=.*/max_execution_time=180/g' /etc/php/7*/apache2/php.ini"]
# RUN ["bin/bash", "-c", "sed -i 's/upload_max_filesize\\s*=.*/upload_max_filesize=16M/g' /etc/php/7*/apache2/php.ini"]
# RUN ["bin/bash", "-c", "sed -i 's/memory_limit\\s*=.*/memory_limit=256M/g' /etc/php/7*/apache2/php.ini"]
# RUN ["bin/bash", "-c", "sed -i 's/post_max_size\\s*=.*/post_max_size=20M/g' /etc/php/7*/apache2/php.ini"]

# Install Ioncube loader
# RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
# RUN tar xvfz ioncube_loaders_lin_x86-64.tar.gz
# RUN ["bin/bash", "-c", "cp ioncube/*.so /usr/lib/php/2*/"]
# RUN ["bin/bash", "-c", "cd /etc/php/7*/apache2/conf.d && echo zend_extension = /usr/lib/php/2*/ioncube_loader_lin_7.0.so > 00-ioncube.ini"]
# RUN service nginx restart

# Configure Nginx
# RUN chown -R www-data:www-data /var/www

# EXPOSE 80
# EXPOSE 443

# CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]