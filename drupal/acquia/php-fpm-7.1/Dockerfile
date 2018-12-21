FROM ubuntu:16.04

# NOTE: This is not a production build: for sandbox/CI use only

# Build dependencies - removed after build is complete
ENV BUILDDEPS autoconf \
        dpkg-dev \
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
        libgmp-dev \
        libgpgme11-dev \
        libjpeg-dev \
        libkrb5-dev \
        libldap2-dev \
        libmagickcore-dev \
        libmagickwand-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libmysqlclient-dev \
        libpng-dev \
        libpq-dev \
        libpspell-dev \
        libreadline-dev \
        libsasl2-dev \
        libsqlite3-dev \
        libssh2-1-dev \
        libssl-dev \
        libtidy-dev \
        libxml2-dev \
        libxpm-dev \
        libxslt-dev \
        libyaml-dev \
        libzip-dev \
        make \
        pkg-config \
        re2c \
        zlib1g-dev

ENV PATH=$PATH:/usr/local/php7.1/bin
COPY currentconfig /usr/src
COPY etc /usr/src/etc

RUN apt-get update && apt-get install -y \
        ${BUILDDEPS} \
        # Permanently installed dependencies
        ca-certificates \
        curl \
        file \
        wget \
        xz-utils \
        --no-install-recommends && rm -r /var/lib/apt/lists/*; \
        \
        . /usr/src/currentconfig; \
        # Download and build php
        cd /usr/src; \
        wget -O php.tar.xz "http://us1.php.net/get/php-${VERSION}.tar.xz/from/this/mirror"; \
        tar xf php.tar.xz; \
        cd /usr/src/php-*; \
        # Workaround for library issue on Ubuntu 16.04
        ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a; \
        ./configure ${CONFIGURE_OPTIONS}; \
        make -j "$(nproc)"; \
        make install; \
        make clean; \
        \
        # Copy the etc configuration into place
        rm -rf "${ETC}"; \
        mv /usr/src/etc "${ETC}"; \
        \
        # Install PHP extensions
        pecl channel-update pecl.php.net; \
        # Install tideways from source (not available from pecl)
        cd /usr/src; \
        wget https://github.com/tideways/php-xhprof-extension/archive/v4.1.5.tar.gz; \
        tar xzf v4.1.5.tar.gz; \
        cd php-xhprof-extension-*; \
        phpize; \
        ./configure; \
        make; \
        make install ;\
        # Install, including ssh2 (which is installed but not via PECL)
        yes '' | pecl install -n ${PECL} ssh2-1.1.2; \
        # php.ini is not pointing to the pecl installation directory, so move the files
        mv /usr/local/php7.1/lib/php/extensions/no-debug-non-zts-20160303/* /usr/local/php7.1/lib/php/extensions; \
        #$ Repeat the install so that extensions with dependencies can install
        yes '' | pecl install -n ${PECL}; \
        # php.ini is not pointing to the pecl installation directory, so move the files
        mv /usr/local/php7.1/lib/php/extensions/no-debug-non-zts-20160303/* /usr/local/php7.1/lib/php/extensions; \
        \
        # Clean up
        cd /usr/src; \
        rm -rf /usr/src/*; \
        apt-get purge -y ${BUILDDEPS}; \
        \
        # Validate that loaded extensions and config match
        if [ "$(php -m | grep -E '^[a-zA-Z0-9]+$' | tr '\n' ',')" != "${EXTENSIONS}" ]; then echo "PHP extensions do not match expected"; exit 1; fi; \
        if [ "$(php -r 'print json_encode(ini_get_all());')" != "${CONFIG}" ]; then echo "PHP config does not match expected"; exit 2; fi