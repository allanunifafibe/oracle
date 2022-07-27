FROM php:7.1-apache

RUN apt-get update

RUN apt-get upgrade -y

RUN apt-get install -y build-essential 
RUN apt-get install -y  unzip
RUN apt-get install -y  vim
RUN apt-get install -y  git
RUN apt-get install -y  libfreetype6-dev
RUN apt-get install -y  libjpeg62-turbo-dev
RUN apt-get install -y  libmcrypt-dev
RUN apt-get install -y  libpng-dev
RUN apt-get install -y  zlib1g-dev
RUN apt-get install -y  libicu-dev
RUN apt-get install -y  g++
RUN apt-get install -y  unixodbc-dev
RUN apt-get install -y  libxml2-dev
RUN apt-get install -y  libaio-dev
RUN apt-get install -y  libgearman-dev
RUN apt-get install -y  libmemcached-dev
RUN apt-get install -y  freetds-dev
RUN apt-get install -y  libssl-dev
RUN apt-get install -y  openssh-server 

RUN ln -sf /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib

RUN cd /etc/apache2 \
  && touch php.ini \
  && echo "extension=oci8.so" >> /etc/apache2/php.ini \
  && echo "export LD_LIBRARY_PATH=/opt/oracle/instantclient_21_7" >> /etc/apache2/envvars \
  && echo "export ORACLE_HOME=/opt/oracle/instantclient_21_7:$LD_LIBRARY_PATH" >> /etc/environment

# Install Oracle Instantclient
RUN cd /opt \
  && git clone https://github.com/allanunifafibe/oracle.git \
  && unzip /opt/oracle/instantclient-basic-linux.x64-21.7.0.0.0dbru -d /opt/oracle \
  && unzip /opt/oracle/instantclient-sdk-linux.x86-21-7.0.0.0dbru -d /opt/oracle \
  && ln -sf /opt/oracle/instantclient_21_7/libclntsh.so.12.1 /opt/oracle/instantclient_21_7/libclntsh.so \
  && ln -sf /opt/oracle/instantclient_21_7/libclntshcore.so.12.1 /opt/oracle/instantclient_21_7/libclntshcore.so \
  && ln -sf /opt/oracle/instantclient_21_7/libocci.so.12.1 /opt/oracle/instantclient_21_7/libocci.so \
  && rm -rf /opt/oracle/*.zip

RUN echo 'instantclient,/opt/oracle/instantclient_21_7/' | pecl install oci8-2.2.0

RUN echo /opt/oracle/instantclient_21_7 > /etc/ld.so.conf.d/oracle-instantclient.conf

RUN ldconfig

RUN docker-php-ext-configure pdo_oci

RUN docker-php-ext-configure pdo_dblib

RUN docker-php-ext-install iconv mbstring intl mcrypt gd mysqli pdo pdo_mysql pdo_oci xml soap 

RUN docker-php-ext-install pdo_oci

RUN docker-php-ext-install pdo_dblib

RUN docker-php-ext-enable oci8

RUN docker-php-ext-enabled opcache

RUN docker-php-ext-enable pdo pdo_mysql

RUN a2enmod rewrite

RUN service apache2 restart

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

EXPOSE 80