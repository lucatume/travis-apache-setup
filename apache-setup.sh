#!/usr/bin/env bash

ROOT_UID="0"

#Check if run as root
if [ "$UID" -ne "$ROOT_UID" ] ; then
    echo "Apache setup script requires root privileges to run: run this script as sudo"
    exit 1
fi

dir="/tmp/site"
url="http://site.dev"
host="127.0.0.1";

OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "fu:" opt; do
    case "$opt" in
    f)  dir=$OPTARG
        ;;
    u)  url=$OPTARG
        ;;
    h)  host=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

script="`readlink -f "${BASH_SOURCE[0]}"`"
scriptDir="`dirname "$script"`"

# update and install apache2 packages
apt-get update
apt-get install -y --force-yes apache2 libapache2-mod-fastcgi make
apt-get install -y --force-yes php5-dev php-pear php5-mysql php5-curl php5-gd php5-json php5-sqlite php5-pgsql
a2enmod headers

# Enable php-fpm
# credit: https://www.marcus-povey.co.uk/2016/02/16/travisci-with-php-7-on-apache-php-fpm/
if [[ ${TRAVIS_PHP_VERSION:0:3} == "7.0" ]]; then sudo cp $scriptDir/assets/www.conf ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.d/; fi
cp ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf.default ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf
a2enmod rewrite actions fastcgi alias
echo "cgi.fix_pathinfo = 1" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
~/.phpenv/versions/$(phpenv version-name)/sbin/php-fpm

  # Configure apache virtual hosts
cp -f $scriptDir/assets/travis-ci-apache /etc/apache2/sites-available/default
sed -e "s?%DIR%?$dir?g" --in-place /etc/apache2/sites-available/default
sed -e "s?%URL%?$url?g" --in-place /etc/apache2/sites-available/default
echo "$host $url" | sudo tee --append /etc/hosts > /dev/null

# Restart services
service apache2 restart