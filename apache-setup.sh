#!/bin/bash

siteDir="/tmp/site"
siteUrl="http://site.dev"
siteHost="127.0.0.1";

OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "f:u:h:" opt; do
    case "$opt" in
    f)  siteDir=$OPTARG
        ;;
    u)  siteUrl=$OPTARG
        ;;
    h)  siteHost=$OPTARG
        ;;
    esac
done

breath="\n\n"
sep="================================================================================\n"

echo "Site from $siteDir will be served on $siteUrl (resolving domain name to $siteHost address)"
printf $sep

shift $((OPTIND-1))

pushd `dirname $0` > /dev/null
script`pwd -P`
popd > /dev/null
scriptDir="`dirname "$script"`"

printf $breath
echo "Updating and installing apache2 packages"
printf $sep

apt-get update
apt-get install -y --force-yes apache2 libapache2-mod-fastcgi make
apt-get install -y --force-yes php5-dev php-pear php5-mysql php5-csiteUrl php5-gd php5-json php5-sqlite php5-pgsql
a2enmod headers

printf $breath
echo "Enabling php-fpm"
printf $sep

# credit: https://www.marcus-povey.co.uk/2016/02/16/travisci-with-php-7-on-apache-php-fpm/
if [[ ${TRAVIS_PHP_VERSION:0:3} == "7.0" ]]; then cp $scriptDir/assets/www.conf ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.d/; fi
cp ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf.default ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf
a2enmod rewrite actions fastcgi alias
echo "cgi.fix_pathinfo = 1" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
~/.phpenv/versions/$(phpenv version-name)/sbin/php-fpm

printf $breath
echo "Configuring Apache virtual hosts"
printf $sep

cp -f $scriptDir/assets/travis-ci-apache /etc/apache2/sites-available/default
sed -e "s?%DIR%?$siteDir?g" --in-place /etc/apache2/sites-available/default
sed -e "s?%URL%?$siteUrl?g" --in-place /etc/apache2/sites-available/default
echo "$siteHost $siteUrl" | tee --append /etc/hosts > /dev/null

printf $breath
echo "Restarting Apache"
printf $sep

service apache2 restart