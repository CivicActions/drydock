FROM ubuntu:16.04

# NOTE: This is not a production build. For sandbox/CI use only.

RUN apt-get update && apt-get install -y \
        autoconf \
        ca-certificates \
        curl \
        dpkg-dev \
        file \
        freetds-dev \
        g++ \
        gcc \
        libbz2-dev \
        libc-client2007e-dev \
        libc-dev \
        libcurl4-openssl-dev \
        libdb-dev \
        libedit-dev \
        libfreetype6-dev \
        libgdbm-dev \
        libgpgme11-dev \
        libgmp-dev \
        libjpeg-dev \
        libkrb5-dev \
        libldap2-dev \
        libmcrypt-dev \
        libmysqlclient-dev \
        libpng-dev \
        libpq-dev \
        libpspell-dev \
        libreadline-dev \
        libsasl2-dev \
        libsqlite3-dev \
        libssl-dev \
        libtidy-dev \
        libxml2-dev \
        libxpm-dev \
        libxslt-dev \
        libzip-dev \
        make \
        pkg-config \
        re2c \
        wget \
        xz-utils \
        zlib1g-dev \
        --no-install-recommends && rm -r /var/lib/apt/lists/*

ENV PATH=$PATH:/usr/local/php7.1/bin
COPY currentconfig /usr/src
RUN . /usr/src/currentconfig; \
        cd /usr/src; \
        wget -O php.tar.xz "http://us1.php.net/get/php-$VERSION.tar.xz/from/this/mirror"; \
        tar xf php.tar.xz; \
        cd /usr/src/php-*; \
        ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a; \
        ./configure $CONFIGURE_OPTIONS; \
        make -j "$(nproc)"; \
        make install; \
        make clean

RUN pecl channel-update pecl.php.net; \
        yes '' | pecl install -f $PECL