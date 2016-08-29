#!/bin/bash

DEBUG=1

# defaults
WP_DIR="/tmp/wordpress"
WP_MULTISITE=0
WP_MUSUBDOMAINS=0
WP_DBNAME="wordpress"
WP_DBUSER="root"
WP_DBPASS=""
WP_DBHOST="localhost"
WP_DBPREFIX="wp_"
WP_DOMAIN="wordpress.dev"
WP_MUBASE="/"
WP_TITLE="Test"
WP_ADMIN_USER="admin"
WP_ADMIN_PASS="admin"
WP_ADMIN_EMAIL="admin@$WP_DOMAIN"
EMPTY=1
WP_THEME="twentysixteen"

PARSED_OPTIONS=$(getopt -n "$0"  -o 'me' --long "dir::,multisite,subdomains,empty,dbname::,dbuser::,dbpass::,dbhost::,dbprefix::,domain::,title::,base::,admin_user::,admin_password::,admin_email::,theme::"  -- "$@")
 
#Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ];
then
  exit 1
fi
 
eval set -- "$PARSED_OPTIONS"

if [[ $DEBUG == 1 ]]; then
    echo "$PARSED_OPTIONS"
fi

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        --dir ) WP_DIR="$2"; shift 2;;
        -m|--multisite ) WP_MULTISITE=1; shift;;
        -s|--subdomains ) WP_MUSUBDOMAINS=1; shift;;
        -e|--empty ) EMPTY=1; shift;;
        --dbname ) WP_DBNAME="$2"; shift 2;;
        --dbuser ) WP_DBUSER="$2"; shift 2;;
        --dbpass ) WP_DBPASS="$2"; shift 2;;
        --dbhost ) WP_DBHOST="$2"; shift 2;;
        --dbprefix ) WP_DBPREFIX="$2"; shift 2;;
        --domain ) WP_DOMAIN="$2"; shift 2;;
        --title ) WP_TITLE="$2"; shift 2;;
        --base ) WP_MUBASE="$2"; shift 2;;
        --admin_user ) WP_ADMIN_USER="$2"; shift 2;;
        --admin_password ) WP_ADMIN_PASS="$2"; shift 2;;
        --admin_email ) WP_ADMIN_EMAIL="$2"; shift 2;;
        --theme ) WP_THEME="$2"; shift 2;;
        --) shift; break;;
    esac
done

if [[ $DEBUG == 1 ]]; then
    echo "WP_DIR is $WP_DIR" 
    echo "WP_MULTISITE is $WP_MULTISITE"
    echo "WP_MUSUBDOMAINS is $WP_MUSUBDOMAINS"
    echo "WP_DBNAME is $WP_DBNAME" 
    echo "WP_DBUSER is $WP_DBUSER" 
    echo "WP_DBPASS is $WP_DBPASS" 
    echo "WP_DBHOST is $WP_DBHOST" 
    echo "WP_DBPREFIX is $WP_DBPREFIX" 
    echo "WP_DOMAIN is $WP_DOMAIN" 
    echo "WP_MUBASE is $WP_MUBASE" 
    echo "WP_TITLE is $WP_TITLE" 
    echo "WP_ADMIN_USER is $WP_ADMIN_USER" 
    echo "WP_ADMIN_PASS is $WP_ADMIN_PASS" 
    echo "WP_ADMIN_EMAIL is $WP_ADMIN_EMAIL" 
    echo "EMPTY is $EMPTY" 
    echo "WP_THEME is $WP_THEME" 
fi

BREATH="\n\n"
SEP="================================================================================\n"


# create the folder that will store the WordPress installation
printf $BREATH
echo "Creating folder $WP_DIR"
mkdir -p WP_DIR$


printf $BREATH
echo "Installing wp-cli; will be globally available as wp"
printf $SEP
# install wp-cli and make it available in PATH
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp/tools/
chmod +x /tmp/tools/wp-cli.phar && mv /tmp/tools/wp-cli.phar /tmp/tools/wp
export PATH=$PATH:/tmp/tools:vendor/bin

printf $BREATH
echo "Downloading WordPress"
printf $SEP
# download wordpress
cd $WP_DIR && wp core download

printf $BREATH
if [[ $WP_MULTISITE == 1 ]]; then
    echo "Configuring WordPress for multisite installation"
    wp core config --dbname=$WP_DBNAME --dbuser=$WP_DBUSER --dbpass=$WP_DBPASS --dbhost=$WP_DBHOST --dbprefix=$WP_DBPREFIX --skip-salts
    wp core multisite-install --url=$WP_DOMAIN --base=$WP_MUBASE --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_EMAIL if [[ $WP_MUSUBDOMAINS == 1 ]]; then "--subdomains" ;fi; --skip-email
elif [[ $WP_MULTISITE == 0 ]]; then
    echo "Configuring WordPress for single site installation"
    wp core config --dbname=$WP_DBNAME --dbuser=$WP_DBUSER --dbpass=$WP_DBPASS --dbhost=$WP_DBHOST --dbprefix=$WP_DBPREFIX --skip-salts
    wp core install --url=$WP_DOMAIN --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_EMAIL --skip-email
fi

printf $SEP

if [[ $EMPTY == 1 ]]; then
    printf $BREATH
    echo "Emptying WordPress installation"
    printf $SEP
    wp site empty --yes
    wp plugin delete $(wp plugin list --field=name)
    wp theme activate $WP_THEME && wp theme delete $(wp theme list --field=name --status=inactive)
fi

wp core version
