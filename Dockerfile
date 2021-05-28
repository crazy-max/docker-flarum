ARG FLARUM_VERSION=v1.0.0

FROM crazymax/yasu:latest AS yasu
FROM crazymax/alpine-s6:3.13-2.2.0.3
LABEL maintainer="CrazyMax"

COPY --from=yasu / /
RUN apk --update --no-cache add \
    bash \
    curl \
    libgd \
    mysql-client \
    nginx \
    php7 \
    php7-cli \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-fileinfo \
    php7-fpm \
    php7-gd \
    php7-gmp \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-phar \
    php7-session \
    php7-simplexml \
    php7-sodium \
    php7-tokenizer \
    php7-xml \
    php7-xmlwriter \
    php7-zip \
    php7-zlib \
    php7-pecl-uuid \
    shadow \
    tar \
    tzdata \
  && rm -rf /tmp/* /var/cache/apk/* /var/www/*

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"\
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

ARG FLARUM_VERSION
RUN mkdir -p /opt/flarum \
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
  && COMPOSER_CACHE_DIR="/tmp" composer create-project flarum/flarum /opt/flarum $FLARUM_VERSION --stability=beta \
  && composer clear-cache \
  && addgroup -g ${PGID} flarum \
  && adduser -D -h /opt/flarum -u ${PUID} -G flarum -s /bin/sh -D flarum \
  && chown -R flarum. /opt/flarum \
  && rm -rf /root/.composer /tmp/*

COPY rootfs /

RUN chmod +x /usr/local/bin/*

EXPOSE 8000
WORKDIR /opt/flarum
VOLUME [ "/data" ]

ENTRYPOINT [ "/init" ]
