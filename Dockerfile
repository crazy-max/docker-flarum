# syntax=docker/dockerfile:1

ARG FLARUM_VERSION=v1.8.8
ARG ALPINE_VERSION=3.19

FROM crazymax/yasu:latest AS yasu
FROM crazymax/alpine-s6:${ALPINE_VERSION}-2.2.0.3

COPY --from=yasu / /
RUN apk --update --no-cache add \
    bash \
    curl \
    libgd \
    mysql-client \
    mariadb-connector-c \
    nginx \
    php82 \
    php82-cli \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-fpm \
    php82-gd \
    php82-gmp \
    php82-iconv \
    php82-intl \
    php82-json \
    php82-mbstring \
    php82-opcache \
    php82-openssl \
    php82-pdo \
    php82-pdo_mysql \
    php82-pecl-uuid \
    php82-phar \
    php82-session \
    php82-simplexml \
    php82-sodium \
    php82-tokenizer \
    php82-xml \
    php82-xmlwriter \
    php82-zip \
    php82-zlib \
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
