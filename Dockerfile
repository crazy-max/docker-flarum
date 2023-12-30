# syntax=docker/dockerfile:1

ARG FLARUM_VERSION=v1.8.3
ARG ALPINE_VERSION=3.18

FROM crazymax/yasu:latest AS yasu
FROM crazymax/alpine-s6:${ALPINE_VERSION}-2.2.0.3

COPY --from=yasu / /
RUN apk --update --no-cache add \
    bash \
    curl \
    libgd \
    mysql-client \
    nginx \
    php81 \
    php81-cli \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-fpm \
    php81-gd \
    php81-gmp \
    php81-iconv \
    php81-intl \
    php81-json \
    php81-mbstring \
    php81-opcache \
    php81-openssl \
    php81-pdo \
    php81-pdo_mysql \
    php81-pecl-uuid \
    php81-phar \
    php81-session \
    php81-simplexml \
    php81-sodium \
    php81-tokenizer \
    php81-xml \
    php81-xmlwriter \
    php81-zip \
    php81-zlib \
    shadow \
    tar \
    tzdata \
  && rm -rf /tmp/* /var/www/*

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"\
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

ARG FLARUM_VERSION
RUN mkdir -p /opt/flarum \
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
  && COMPOSER_CACHE_DIR="/tmp" composer create-project flarum/flarum /opt/flarum --no-install \
  && COMPOSER_CACHE_DIR="/tmp" composer require --working-dir /opt/flarum flarum/core:${FLARUM_VERSION} \
  && composer clear-cache \
  && addgroup -g ${PGID} flarum \
  && adduser -D -h /opt/flarum -u ${PUID} -G flarum -s /bin/sh -D flarum \
  && chown -R flarum. /opt/flarum \
  && rm -rf /root/.composer /tmp/*

COPY rootfs /

EXPOSE 8000
WORKDIR /opt/flarum
VOLUME [ "/data" ]

ENTRYPOINT [ "/init" ]
