# Travis CI Apache Virtualhost configuration script

This script will install and set up Apache to serve a folder using virtual host in the context of a Travis CI PHP build.

## Installation
Clone the repository (in the context of a CI script) into the `setup` folder:

```bash
git clone https://github.com/lucatume/travis-apache-setup.git setup
```

## Usage
The script is tailored on Travis CI PHP build images and might not work in every situation.
In the example below I'm assuming the repository has been cloned in the `./setup` folder.
The repository defines two setup scripts: one to install WordPress and one to setup apache to serve a website from a folder on a local domain:

### The WordPress installation script
The script requires defining the parameters that will be passed to the [wp-cli](http://wp-cli.org/ "Command line interface for WordPress - WP-CLI") tool to setup and install a WordPress site.
Refer to the [wp-cli site installation commands to find out more](http://wp-cli.org/commands/core/install/ "wp core install - WP-CLI").

```bash
sh ./setup/wp-install --dir=/tmp/wordpress \
    --dbname="$wpDbName" --dbuser="root" \
    --dbpass="" --dbprefix=wp_ --domain="wordpress.dev" \
    --title="Test" --admin_user=admin --admin_password=admin \
    --admin_email=admin@wordpress.dev --theme=twentysixteen --empty
```

The `--dir` and `--domain` options should match the `f` and `u` option specified in the `apache-setup` command below.
As a required tool the script will also make the `wp` command ([wp-cli](http://wp-cli.org/ "Command line interface for WordPress - WP-CLI"))available on the PATH for the CI user to use.

### The Apache setup script
Call the script with `sudo`:

```bash
sudo sh ./setup/apache-setup -h="127.0.0.1" -u="http://wp.local" -f="/var/www/wp"
```

The options:

* h - as "host" allows specifying the localhost address, defaults to `127.0.0.1`
* f - as "folder" allows specifying the folder the site should be served from; defaults to `/tmp/site`
* u - as "url" allows specifying the url the site should be served at; defaults to `http://site.dev`
