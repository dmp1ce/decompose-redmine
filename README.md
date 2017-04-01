Redmine environment for Decompose intended to help developers quickly start a Redmine website. Because this project uses Docker instead of a virtual machine, the website is suitable for production as well as development and testing!

# Requirements

- [Decompose](https://github.com/dmp1ce/decompose)
- [Docker](http://www.docker.com/)
- [Docker Compose](http://docs.docker.com/compose/)

# Quick Start

``` bash
decompose --init https://github.com/dmp1ce/decompose-redmine.git

# Set the version of Redmine to use (lastest of master branch is default)
git -C containers/passenger/redmine checkout 3.3-stable

# Initialize Redmine for the the first start
decompose initialize_redmine
```

After the initial start use:

```
decompose build && decompose up
```

Then visit `http://localhost/` to view Redmine. Username, password and host information for the database can be modified in the `.decompose/elements` file.

# Usage

Decompose uses skeleton files in the `.decompose/environment/skel` to create a starting point for working on Redmine. Decompose will also initialize a git repository, so `git status` will show all of the files which have been created for you. Some of the files created are `.mo` files which are template files and contain elements (variables) like `{{PROJECT_NAME}}`. These elements are defined throughout the project but primarily in `elements` and `.decompose/elements`. Many tasks can be done with a decompose process such as `decompose build` or `decompose up`.

## File structure

After `decompose --init https://github.com/dmp1ce/decompose-redmine.git` is run, the following directory structure will be created.
```
├── containers
│   └── passenger
│       ├── Dockerfile
│       ├── redmine
│       ├── redmine.conf.mo
│       └── redmine_plugins
├── docker-compose.yml.mo
└── README.md
```
The containers directory is the configuration for all containers used by Redmine. The backup and backup_data containers are used for backing up Redmine files and database settings using Duply. The data container stores Redmine uploaded files. The passenger container containers the nginx configuration for Redmine. The nginx_proxy directory is a special directory for configuration the nginx_proxy container which can host multiple websites from the same host! See [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy).

The `docker-compose.yml.mo` is a template file for creating the `docker-compose.yml` file. This file configures how each container interacts with each other. It also configures various settings such as environment variables, labels and restart settings.

The elements file contains non-private elements. Private elements such as passwords or API keys go in `.decompose/elements` and are not checked in. See [elements section](#elements) for details.

The processes file contains non-private processes. Private processes such as development only processes go in `.decompose/processes` and are not checked in. See [processes section](#processes) for details.

TODO: Go into more detail about each container which is used.

## Elements

Elements are essentually variables which can be used to change files generated from template files. Template files are any file with the extension `.mo`. Although, you can exclude `.mo` files from being processed using the `PROJECT_IGNORE_BUILD` element.

You can create your own elmeents by adding them to the `.decompose/elements` file if they are private and show not be checked in. If they are OK to be checked in and show to the public then you can add them to `elements` as long as `elements` is referenced by `.decompose/elments`.

### List of Elements

#### General Elements
- `PROJECT_ENVIRONMENT` : The current environment. Only `development` or `production` is supported.
- `PROJECT_NGINX_VIRTUAL_HOST` : The primary hostname used by nginx. This is what all other hosts will redirect to.
- `PROJECT_NGINX_VIRTUAL_HOST_ALTS` : All alternative hostnames. These are valid hostnames but they will be redirected to the `$PROJECT_NGINX_VIRTUAL_HOST` hostname. Multiple hostnames should be seperated by a space character. For example: `PROJECT_NGINX_VIRTUAL_HOST="example.com www.example.com"`
- `PROJECT_NGINX_DEFAULT_HOST` : Tells nginx_proxy where to go if it cannot find a matching domain. Be careful with this setting as it can override other projects which share the same nginx_proxy container.
- `PROJECT_NGINX_PROXY_IMAGE` : Specify the nginx-proxy image to use. [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) is the default image.

#### Database Elements
- `PROJECT_DB_USER` : Redmine database user
- `PROJECT_DB_DATABASE` : Redmine database name
- `PROJECT_DB_PASSWORD` : Redmine database user password
- `PROJECT_DB_ROOT_PASSWORD` : Redmine root user password

#### Backup Elements
- `PROJECT_BACKUP_GPG_KEY` : GPG key to use for encrypting backup
- `PROJECT_BACKUP_GPG_PW` : GPG password needed to use the key
- `PROJECT_BACKUP_TARGET` : Target location to send backup according to Duply documenation
- `PROJECT_BACKUP_CONFIG_TARGET` : Target location to send configuration backup. Unlike `PROJECT_BACKUP_TARGET` this uses scp scheme and not the Duply scheme.
- `PROJECT_BACKUP_SOURCE` : The location of the source to backup. Default is `/srv/http/source`.

#### Production Elements
- `PROJECT_PRODUCTION_SERVER_IP` : IP of production server
- `PROJECT_PRODUCTION_SERVER_USER` : User of production server which you connect to with SSH
- `PROJECT_PRODUCTION_SERVER_BASE_PATH` : Relative path from home which the project is located on production

#### Reverse Proxy Elements
- `PROJECT_WEBSITE_TO_EXPOSE_IP` : IP of machine which you want to expose from the reverse proxy server. `localhost` or the IP of a virtual machine most likely.
- `PROJECT_WEBSITE_TO_EXPOSE_PORT` : The port of the machine to expose from the reverse proxy server.
- `PROJECT_REVERSE_PROXY_USER` : The user used to SSH into the reverse proxy
- `PROJECT_REVERSE_PROXY_IP` : IP of the reverse proxy
- `PROJECT_REVERSE_PROXY_PORT` : The port of the reverse proxy which will map to the `PROJECT_WEBSITE_TO_EXPOSE_PORT`

TODO: grep for more, possibly hidden, elements

## Processes

Processes are typically common tasks that are needed when working on the project. Custom processes can be added to the `.decompose/processes` file. If you want to check in your processes then add them to `processes` and reference the file in `.decompose/processes`. See the `.decompose/processes` file for a simple example.

### List of Processes

`decompose --help` for list of processes

- `build` : Process template files and build Docker containers
- `up` : Start or restart Docker containers
- `explore_db` : Open a command prompt to MariaDB Redmine database
- `env` : Shows if the current configuration is in production or development mode and shows URL host settings

### Additional Processes from decompose libraries
TODO: Instead of listing all of the processes provided by libraries, instead link to the library documentation when it is completed.

- `start_nginx_proxy` : Starts the nginx proxy container if it isn't already running
- `restart_nginx_proxy` : Restarts the nginx proxy container. If it isn't running then it will be started.
- `recreate_nginx_proxy` : Like restart but makes sure to create a new container instead of reusing an old one
- `start-reverse-proxy` : Starts a reverse proxy connection for exposing local environment to Internet. See element settings for `PROJECT_WEBSITE_TO_EXPOSE_IP`, `PROJECT_WEBSITE_TO_EXPOSE_PORT` and `│PROJECT_REVERSE_PROXY_*`. Also requires a properly configured SSH server to already be running.
- `update-production-server-to-latest` : Script for deploying currently checked in code to production server. See elements `PROJECT_PRODUCTION_SERVER_*`.
- `increment-tag` : Increments the last version tag by 1. For example v1.1 would be incremented to v1.2
- `ssh_production` : SSH into production server. Uses the same elmeents as `update-production-server-to-latest`.
- `generate_nginx_proxy_configs` : Generates the nginx proxy configuration files. See nginx_proxy container for details.
- `project-root` : Print project root directory
- `backup_config` : Backup all files which are not checked in. Important if for some reason the server is deleted and the configuration is needed to restore the site backup. See backup lib.
- `generate_gpg_backup_keys` : Generate GPG keys for backing up database and uploaded files.
- `generate_backup_server_ssh_access_key` : Generate SSH keys for accessing backup server to store backups
- `list-backups` : List all currently known backups. Useful for finding a backup to restore to.
- `restore-db` : Restore database from a backup
- `remove-untagged-docker-images` : Remove all untagged docker images. Useful for keeping Docker from using up all hard drive space.

# Local development

For developing modules or hacking on Redmine, you'll probably want to be able to edit files and see the results right away on the website without needing to rebuild the project with `decompose build && decompose up`. Setting the element `PROJECT_ENVIRONMENT` to `development` should achieve this. Modify the Redmine source in `containers/passenger/redmine` or add your own plugins to `containers/passenger/redmine_plugins`.
