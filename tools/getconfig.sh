#!/usr/bin/env bash
echo export VERSION=\'$(php-config --version)\'
echo export CONFIGURE_OPTIONS=\'$(php-config --configure-options)\'
echo export PECL=\'$(pecl list | grep -F stable | awk '{print $1"-"$2}' | tr '\n' ' ')\'
echo export EXTENSIONS=\'$(php -m | grep -Fv '[' | tr '\n' ' ')\'