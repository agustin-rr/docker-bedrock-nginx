
# Docker Compose of Bedrock (WordPress) with Nginx

Quickly create an environment to work with [Bedrock](https://roots.io/bedrock).

**Bedrock** - Modern development tools, easier configuration, and an improved secured folder structure for [WordPress](https://es.wordpress.org/).


## Contents

+ When it starts it installs the latest version of Bedrock.
+ Use only official Docker images.
+ Choose [MariaDB](https://hub.docker.com/_/mariadb) or [MySQL](https://hub.docker.com/_/mysql). It's up to you.
+ Maximum optimization with [PHP-FPM](https://hub.docker.com/_/php) of Alpine. You choose the version.
+ Custom domain with HTTPS. So you can use for example [https://local.wp-nginx.com](https://local.wp-nginx.com).
+ Custom Nginx config.
+ Custom PHP config.
+ [WP-CLI](https://wp-cli.org/) included - WP-CLI is the command-line interface for WordPress.
+ [PhpMyAdmin](https://www.phpmyadmin.net/) included - free and open source administration tool for MySQL and MariaDB.


## Instructions

<details>
 <summary>Requirements</summary>

+ [Docker](https://www.docker.com/get-started)
+ [mkcert](https://github.com/FiloSottile/mkcert) for creating the SSL cert.

> `mkcert` needs to be installed like described in Requirements. Read more for [Linux](https://github.com/FiloSottile/mkcert#linux), [Windows](https://github.com/FiloSottile/mkcert#windows) or [macOS](https://github.com/FiloSottile/mkcert#macos).
</details>


<details>
 <summary>Install</summary>

1. Copy `.env.example` in the project root to `.env` and edit your preferences.

    If you use `Linux` or `MacOS` run:

    ```shell
    $ id
    ```
    Copy your `uid` and `gid` into the `USER_ID` and `GROUP_ID` variables.

2. Run:
    ```shell
    $ docker/install.sh
    ```

    This script will create a locally-trusted development certificates. It requires no configuration.


3. Make sure your `/etc/hosts` file has a record for used domain. On Windows the hosts file can be find at `C:\Windows\System32\drivers\etc`. Make sure to open it with admin rights.

    ```
    sudo vi /etc/hosts
    ```

    Add your domain like this:

    ```
    127.0.0.1 local.wp-nginx.com
    ```
</details>

<details>
 <summary>Run</summary>

```shell
docker-compose up -d
```

For the first time only, open the `bedrock/.env` file and customize the variables to your preferences. For example:

```dotenv
DB_NAME='wordpress'
DB_USER='wp_user'
DB_PASSWORD='T00many$ecrets'
DB_HOST='db'
DB_PREFIX='xyz_'
WP_ENV='development'
WP_HOME='https://local.wp-nginx.com'
WP_SITEURL="${WP_HOME}/wp"
```

And now you can open [https://local.wp-nginx.com](https://local.wp-nginx.com) in your browser.
</details>


<details>
 <summary>Bedrock</summary>

If your project is empty it will install the latest version of Bedrock for you.
</details>


<details>
 <summary>MariaDB/MySQL</summary>

Avoid problems in the future defining character-set and collation by environment variables.

Allows you to create a new database or use an existing one.

To create from an existing one, leave the dump inside the docker folder `${DOCKER_PATH}/db/init-db/` before starting the container for the first time.
</details>


<details>
 <summary>Nginx</summary>

It uses templates so it is not necessary to define the domain from the configuration files. Just use the `DOMAIN` environment variable.
</details>


<details>
 <summary>WP-CLI</summary>

The container includes WP-CLI. You can use it from the terminal:

```
$ docker-compose exec --user www-data wordpress wp post list
```

To avoid typing so much you can add to `.bashrc`:
```
alias wpd="docker-compose exec --user www-data wordpress wp"
```
restart your terminal and then:
```
$ wpd post list
```
</details>


<details>
 <summary>Certs</summary>

`mkcert` certificates have a lifetime of 2 years by default. If it expires, just run the `install.sh` script again.
</details>


<details>
 <summary>Production</summary>

Although it is created for development I think it can be easily modified for production.
</details>
