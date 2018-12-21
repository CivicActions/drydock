#!/usr/bin/env bash
echo export VERSION=\'$(php-config --version)\'
echo export CONFIGURE_OPTIONS=\'$(php-config --configure-options)\'
echo export PECL=\'$(pecl list | grep -F stable | awk '{print $1"-"$2}' | tr '\n' ' ')\'
echo export EXTENSIONS=\'$(php -m | sed -e 's/\r//g' | grep -E '^[a-zA-Z0-9]+$' | tr '\n' ',')\'
echo export ETC=\'$(php -i | grep -e 'Loaded Configuration File' | sed -e's/[^\/]*//' -e's/\/etc\/.*/\/etc/')\'
echo export CONFIG=\'$(php -r 'print json_encode(ini_get_all());')\'