# Travis CI Apache Virtualhost configuration script

This script will install and set up Apache to serve a folder using virtual host in the context of a Travis CI PHP build.

## Installation
Clone the repository 

```shell
git clone https://github.com/lucatume/travis-apache-setup.git setup
```

## Usage
The script is tailored on Travis CI PHP build images and might not work in every situation.

Call the script with `sudo`:

```shell
sudo sh ./setup/travis-ci-apache -h=127.0.0.1 -u=site.dev -f=/var/www/site
```

The options:

* h - as "host" allows specifying the localhost address, defaults to `127.0.0.1`
* f - as "folder" allows specifying the folder the site should be served from; defaults to `/tmp/site`
* u - as "url" allows specifying the url the site should be served at; defaults to `http://site.dev`