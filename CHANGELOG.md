# Changelog

## 1.0.0-r2 (2021/08/01)

* Alpine Linux 3.14
* PHP 8
* Drop linux/386, linux/ppc64le and linux/s390x support
* Add `FLARUM_POWEREDBY_HEADER` and `FLARUM_REFERRER_POLICY` env vars

## 1.0.0-r1 (2021/05/28)

* Touch `rev-manifest.json`

## 1.0.0-r0 (2021/05/28)

* Flarum 1.0.0
* Alpine Linux 3.13
* alpine-s6 2.2.0.3
* Update examples

## 0.1.0-beta.16-r1 (2021/03/18)

* Downgrade to Alpine Linux 3.12

## 0.1.0-beta.16-r0 (2021/03/18)

* Flarum 0.1.0-beta.16
* Alpine Linux 3.13

## 0.1.0-beta.15-r4 (2021/03/04)

* Renamed `yasu` (more info https://github.com/crazy-max/yasu#yet-another)

## 0.1.0-beta.15-r3 (2021/03/03)

* Switch to `gosu`
* Add `php7-gmp` (#28)

## 0.1.0-beta.15-r2 (2021/02/24)

* Switch to buildx bake
* Do not fail on permission issue

## 0.1.0-beta.15-RC1 (2020/12/21)

* Flarum 0.1.0-beta.15

## 0.1.0-beta.14-RC1 (2020/10/27)

* Flarum 0.1.0-beta.14
* Allow to clear environment in FPM workers

## 0.1.0-beta.13-RC4 (2020/09/20)

* Add missing PHP extensions

## 0.1.0-beta.13-RC3 (2020/08/09)

* Now based on [Alpine Linux 3.12 with s6 overlay](https://github.com/crazy-max/docker-alpine-s6/)

## 0.1.0-beta.13-RC2 (2020/05/17)

* Add `LISTEN_IPV6` env var

## 0.1.0-beta.13-RC1 (2020/05/06)

* Flarum 0.1.0-beta.13

## 0.1.0-beta.12-RC3 (2020/04/09)

* Add php7-exif (#1)
* Switch to Open Container Specification labels as label-schema.org ones are deprecated

## 0.1.0-beta.12-RC2 (2020/03/27)

* Fix folder creation

## 0.1.0-beta.12-RC1 (2020/03/04)

* Flarum 0.1.0-beta.12
* Alpine Linux 3.11

## 0.1.0-beta.11-RC3 (2020/01/24)

* Move Nginx temp folders to `/tmp`

## 0.1.0-beta.11-RC2 (2019/12/07)

* Fix timezone

## 0.1.0-beta.11-RC1 (2019/11/28)

* Flarum 0.1.0-beta.11

## 0.1.0-beta.10-RC2 (2019/11/26)

* Fix perms

## 0.1.0-beta.10-RC1 (2019/11/26)

* Initial version based on Flarum 0.1.0-beta.10
