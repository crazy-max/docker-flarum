# syntax=docker/dockerfile:experimental
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:3.11

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n"

LABEL maintainer="CrazyMax" \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.url="https://github.com/crazy-max/docker-flarum" \
  org.opencontainers.image.source="https://github.com/crazy-max/docker-flarum" \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.revision=$VCS_REF \
  org.opencontainers.image.vendor="CrazyMax" \
  org.opencontainers.image.title="Flarum" \
  org.opencontainers.image.description="Flarum simple forum" \
  org.opencontainers.image.licenses="MIT"

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
    php7-tokenizer \
    php7-xml \
    php7-xmlwriter \
    php7-zip \
    php7-zlib \
    shadow \
    su-exec \
    tar \
    tzdata \
  && S6_ARCH=$(case ${TARGETPLATFORM:-linux/amd64} in \
    "linux/amd64")   echo "amd64"   ;; \
    "linux/arm/v6")  echo "arm"     ;; \
    "linux/arm/v7")  echo "armhf"   ;; \
    "linux/arm64")   echo "aarch64" ;; \
    "linux/386")     echo "x86"     ;; \
    "linux/ppc64le") echo "ppc64le" ;; \
    "linux/s390x")   echo "s390x"   ;; \
    *)               echo ""        ;; esac) \
  && echo "S6_ARCH=$S6_ARCH" \
  && wget -q "https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-${S6_ARCH}.tar.gz" -qO "/tmp/s6-overlay-amd64.tar.gz" \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  && s6-echo "s6-overlay installed" \
  && rm -rf /tmp/* /var/cache/apk/* /var/www/*

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"\
  FLARUM_VERSION="v0.1.0-beta.12" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

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
