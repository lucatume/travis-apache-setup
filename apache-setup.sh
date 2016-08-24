#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  echo "This script requires root access, run it as sudo" 2>&1
  exit 1
fi

siteDir="/tmp/site"
siteUrl="http://site.dev"
siteHost="127.0.0.1";

OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "fuh:" opt; do
    case "$opt" in
    f)  siteDir=$OPTARG
        ;;
    u)  siteUrl=$OPTARG
        ;;
    h)  host=$OPTARG
        ;;
    esac
done

echo "Site from $siteDir will be served on $siteUrl (resolving to $siteHost)"

shift $((OPTIND-1))

script="`readlink -f "${BASH_SOURCE[0]}"`"
scriptDir="`dirname "$script"`"

echo "Updating and installing apache2 packages"
apt-get update
apt-get install -y --force-yes apache2 libapache2-mod-fastcgi make
apt-get install -y --force-yes php5-dev php-pear php5-mysql php5-csiteUrl php5-gd php5-json php5-sqlite php5-pgsql
a2enmod headers

echo "Enabling php-fpm"
# credit: https://www.marcus-povey.co.uk/2016/02/16/travisci-with-php-7-on-apache-php-fpm/
if [[ ${TRAVIS_PHP_VERSION:0:3} == "7.0" ]]; then cp $scriptDir/assets/www.conf ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.d/; fi
cp ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf.default ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf
a2enmod rewrite actions fastcgi alias
echo "cgi.fix_pathinfo = 1" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
~/.phpenv/versions/$(phpenv version-name)/sbin/php-fpm

echo "Configuring Apache virtual hosts"
cp -f $scriptDir/assets/travis-ci-apache /etc/apache2/sites-available/default
sed -e "s?%DIR%?$siteDir?g" --in-place /etc/apache2/sites-available/default
sed -e "s?%URL%?$siteUrl?g" --in-place /etc/apache2/sites-available/default
echo "$siteHost $siteUrl" | tee --append /etc/hosts > /dev/null

echo "Restarting Apache"
service apache2 restart