# syntax=docker/dockerfile:1

ARG FLARUM_VERSION=v2.0.2
ARG ALPINE_VERSION=3.24

FROM tianon/gosu:latest AS gosu

FROM alpine:${ALPINE_VERSION}
COPY --from=gosu /gosu /usr/local/bin/
RUN apk --update --no-cache add \
    bash \
    curl \
    jq \
    libgd \
    mysql-client \
    mariadb-connector-c \
    nginx \
    php85 \
    php85-cli \
    php85-ctype \
    php85-curl \
    php85-dom \
    php85-exif \
    php85-fileinfo \
    php85-fpm \
    php85-gd \
    php85-gmp \
    php85-iconv \
    php85-intl \
    php85-json \
    php85-mbstring \
    php85-openssl \
    php85-pdo \
    php85-pdo_mysql \
    php85-pecl-uuid \
    php85-phar \
    php85-session \
    php85-simplexml \
    php85-sodium \
    php85-tokenizer \
    php85-xml \
    php85-xmlwriter \
    php85-zip \
    php85-zlib \
    s6-overlay \
    shadow \
    tar \
    tzdata \
  && rm -rf /tmp/* /var/www/*

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
  S6_STAGE2_HOOK="/etc/s6-overlay/scripts/runtime-bundles" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

ARG FLARUM_VERSION
RUN mkdir -p /opt/flarum \
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
  && COMPOSER_CACHE_DIR="/tmp" composer create-project flarum/flarum /opt/flarum "^2.0" --no-install \
  && COMPOSER_CACHE_DIR="/tmp" composer require --working-dir /opt/flarum flarum/core:${FLARUM_VERSION} --update-no-dev \
  && composer clear-cache \
  && addgroup -g ${PGID} flarum \
  && adduser -D -h /opt/flarum -u ${PUID} -G flarum -s /bin/sh -D flarum \
  && chown -R flarum:flarum /opt/flarum \
  && rm -rf /root/.composer /tmp/*

COPY rootfs /

EXPOSE 8000
WORKDIR /opt/flarum
VOLUME [ "/data" ]

ENTRYPOINT [ "/init" ]
