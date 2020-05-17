<p align="center"><a href="https://github.com/crazy-max/docker-flarum" target="_blank"><img height="128" src="https://raw.githubusercontent.com/crazy-max/docker-flarum/master/.res/docker-flarum.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/crazymax/flarum/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/crazy-max/docker-flarum?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/crazy-max/docker-flarum/actions?workflow=build"><img src="https://github.com/crazy-max/docker-flarum/workflows/build/badge.svg" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/flarum/"><img src="https://img.shields.io/docker/stars/crazymax/flarum.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/flarum/"><img src="https://img.shields.io/docker/pulls/crazymax/flarum.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://www.codacy.com/app/crazy-max/docker-flarum"><img src="https://img.shields.io/codacy/grade/c214f6492b864734a41a9922360ee4d8.svg?style=flat-square" alt="Code Quality"></a>
  <br /><a href="https://github.com/sponsors/crazy-max"><img src="https://img.shields.io/badge/sponsor-crazy--max-181717.svg?logo=github&style=flat-square" alt="Become a sponsor"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [Flarum](https://flarum.org/) Docker image based on Alpine Linux.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other 🐳 Docker images!

💡 Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun) project!

___

* [Features](#features)
* [Docker](#docker)
  * [Multi-platform image](#multi-platform-image)
  * [Environment variables](#environment-variables)
    * [General](#general)
    * [Flarum](#flarum)
    * [Database](#database)
  * [Volumes](#volumes)
  * [Ports](#ports)
* [Usage](#usage)
  * [Docker Compose](#docker-compose)
  * [Command line](#command-line)
* [Upgrade](#upgrade)
* [Notes](#notes)
  * [First launch](#first-launch)
  * [Manage extensions](#manage-extensions)
  * [Manage extensions](#manage-extensions)
* [How can I help?](#how-can-i-help)
* [License](#license)

## Features

* Run as non-root user
* Multi-platform image
* [s6-overlay](https://github.com/just-containers/s6-overlay/) as process supervisor
* [Traefik](https://github.com/containous/traefik-library-image) as reverse proxy and creation/renewal of Let's Encrypt certificates (see [this template](examples/traefik))

## Docker

### Multi-platform image

Following platforms for this image are available:

```
$ docker run --rm mplatform/mquery crazymax/flarum:latest
Image: crazymax/flarum:latest
 * Manifest List: Yes
 * Supported platforms:
   - linux/amd64
   - linux/arm/v6
   - linux/arm/v7
   - linux/arm64
   - linux/386
   - linux/ppc64le
```

### Environment variables

#### General

* `TZ`: The timezone assigned to the container (default `UTC`)
* `PUID`: Flarum user id (default `1000`)
* `PGID`: Flarum group id (default `1000`)
* `MEMORY_LIMIT`: PHP memory limit (default `256M`)
* `UPLOAD_MAX_SIZE`: Upload max size (default `16M`)
* `OPCACHE_MEM_SIZE`: PHP OpCache memory consumption (default `128`)
* `LISTEN_IPV6`: Enable IPv6 for Nginx (default `true`)
* `REAL_IP_FROM`: Trusted addresses that are known to send correct replacement addresses (default `0.0.0.0/32`)
* `REAL_IP_HEADER`: Request header field whose value will be used to replace the client address (default `X-Forwarded-For`)
* `LOG_IP_VAR`: Use another variable to retrieve the remote IP address for access [log_format](http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format) on Nginx. (default `remote_addr`)

#### Flarum

* `FLARUM_DEBUG`: Enables or disables debug mode, used to troubleshoot issues (default `false`)
* `FLARUM_BASE_URL`: The URL to your Flarum installation **required**
* `FLARUM_FORUM_TITLE`: Flarum forum title, only used during first installation (default `Flarum Dockerized`)
* `FLARUM_API_PATH`: Flarum api path (default `api`)
* `FLARUM_ADMIN_PATH`: Flarum admin path (default `admin`)

#### Database

* `DB_HOST`: MySQL database hostname / IP address **required**
* `DB_PORT`: MySQL database port (default `3306`)
* `DB_NAME`: MySQL database name (default `flarum`)
* `DB_USER`: MySQL user (default `flarum`)
* `DB_PASSWORD`: MySQL password
* `DB_PREFIX`: MySQL database prefix (default `flarum_`)
* `DB_TIMEOUT`: Time in seconds after which we stop trying to reach the MySQL server (useful for clusters, default `60`)

### Volumes

* `/data`: Contains assets, extensions and storage

> :warning: Note that the volume should be owned by the user/group with the specified `PUID` and `PGID`. If you don't give the volume correct permissions, the container may not start.

### Ports

* `8000`: HTTP port

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. You can use the following [docker compose template](examples/compose/docker-compose.yml), then run the container:

```bash
docker-compose up -d
docker-compose logs -f
```

### Command line

You can also use the following minimal command:

```bash
docker run -d -p 8000:8000 --name flarum \
  -v $(pwd)/data:/data \
  -e "DB_HOST=db" \
  -e "FLARUM_BASE_URL=http://127.0.0.1:8000" \
  crazymax/flarum:latest
```

> `-e "DB_HOST=db"`<br />
> :warning: `db` must be a running MySQL instance

## Upgrade

You can upgrade Flarum automatically through the UI, it works well. But I recommend to recreate the container whenever I push an update:

```bash
docker-compose pull
docker-compose up -d
```

## Notes

### First launch

On first launch, an initial administrator user will be created:

| Login    | Password |
|----------|----------|
| `flarum` | `flarum` |

### Manage extensions

You can install [Flarum extensions](https://flagrow.io/extensions) from the command line using a [specially crafted script](rootfs/usr/local/bin/extension) with this image:

`docker-compose exec flarum extension require <package>`

To remove an extension:

`docker-compose exec flarum extension remove <package>`

To list all extensions:

`docker-compose exec flarum extension list`

Example with [`flagrow/upload`](https://flagrow.io/extensions/flagrow/upload) extension:

```
$ docker-compose exec flarum extension require flagrow/upload
Using version ^0.7.1 for flagrow/upload
./composer.json has been updated
Loading composer repositories with package information
Updating dependencies (including require-dev)
Package operations: 2 installs, 0 updates, 0 removals
  - Installing ramsey/uuid (3.8.0): Downloading (100%)
  - Installing flagrow/upload (0.7.1): Downloading (100%)
ramsey/uuid suggests installing ircmaxell/random-lib (Provides RandomLib for use with the RandomLibAdapter)
ramsey/uuid suggests installing ext-libsodium (Provides the PECL libsodium extension for use with the SodiumRandomGenerator)
ramsey/uuid suggests installing ext-uuid (Provides the PECL UUID extension for use with the PeclUuidTimeGenerator and PeclUuidRandomGenerator)
ramsey/uuid suggests installing moontoast/math (Provides support for converting UUID to 128-bit integer (in string form).)
ramsey/uuid suggests installing ramsey/uuid-doctrine (Allows the use of Ramsey\Uuid\Uuid as Doctrine field type.)
ramsey/uuid suggests installing ramsey/uuid-console (A console application for generating UUIDs with ramsey/uuid)
flagrow/upload suggests installing league/flysystem-aws-s3-v3 (Uploads to AWS S3 using API version 3.)
flagrow/upload suggests installing techyah/flysystem-ovh (Uploads to OVH Swift vfs using API.)
Writing lock file
Generating autoload files
Carbon 1 is deprecated, see how to migrate to Carbon 2.
https://carbon.nesbot.com/docs/#api-carbon-2
    You can run './vendor/bin/upgrade-carbon' to get help in updating carbon and other frameworks and libraries that depend on it.
flagrow/upload extension added
```

> :warning: You cannot use [Bazaar marketplace extension](https://discuss.flarum.org/d/5151-bazaar-the-extension-marketplace) to install extensions for now.

## How can I help?

All kinds of contributions are welcome :raised_hands:! The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon: You can also support this project by [**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max) :clap: or by making a [Paypal donation](https://www.paypal.me/crazyws) to ensure this journey continues indefinitely! :rocket:

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.
