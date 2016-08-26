#!/bin/bash

# Downloads, installs and set up a WordPress installation.


# read the options
OPTS=`getopt --long dir,url,title,admin_user,admin_password,admin_email,dbname,dbuser,dbpass,dbhost,dbprefix,multisite,base,subdomains: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo "$OPTS"
eval set -- "$OPTS"

WP_DIR="/tmp/wordpress"
WP_URL="http://wordpress.dev"
WP_TITLE="Test"
WP_ADMIN_USER="admin";
WP_ADMIN_PASS="admin";
WP_ADMIN_EMAIL="admin@wordpress.dev";
WP_DBNAME="wp";
WP_DBUSER="root";
WP_DBPASS="root";
WP_DBHOST="localhost";
WP_DBPREFIX="wp_"
WP_MULTISITE=0
WP_MUBASE="/"
WP_MUSUBDOMAINS=1

while true; do
  case "$1" in
    --dir ) WP_DIR=$2; shift ;;
    --url ) WP_URL=$2; shift ;;
    --title ) WP_TITLE=$2; shift ;;
    --admin_user ) WP_ADMIN_USER=$2; shift ;;
    --admin_password ) WP_ADMIN_PASS=$2; shift ;;
    --admin_email ) WP_ADMIN_EMAIL=$2; shift ;;
    --dbname ) WP_DBNAME=$2; shift ;;
    --dbuser ) WP_DBUSER=$2; shift ;;
    --dbpass ) WP_DBPASS=$2; shift ;;
    --dbhost ) WP_DBHOST=$2; shift ;;
    --dbprefix ) WP_DBPREFIX=$2; shift ;;
    --multisite ) WP_MULTISITE=$2; shift ;;
    --base ) WP_MUBASE=$2; shift ;;
    --subdomains ) WP_MUSUBDOMAINS=$2; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

BREATH="\n\n"
SEP="================================================================================\n"

printf $BREATH
echo "WordPress will be installed with these settings:"
echo "dir: $WP_DIR"
echo "url: $WP_URL"
echo "title: $WP_TITLE"
echo "admin username: $WP_ADMIN_USER"
echo "admin_password: $WP_ADMIN_PASS"
echo "admin email: $WP_ADMIN_EMAIL"
echo "databse name: $WP_DBNAME"
echo "databse user: $WP_DBUSER"
echo "databse password: $WP_DBPASS"
echo "databse host: $WP_DBHOST"
echo "databse table prefix: $WP_DBPREFIX"
echo "multisite: $WP_MULTISITE"
if [[ $WP_MULTISITE ]]; then
    echo "multisite base: $WP_MUBASE"
    echo "multisite subdomains: $WP_MUSUBDOMAINS"
fi

printf $BREATH
echo "Installing wp-cli"
printf "$SEP"

//wwid