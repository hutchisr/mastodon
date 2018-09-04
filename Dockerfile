FROM homulilly/ruby:2.5.1

LABEL maintainer="https://github.com/rainyday/mastodon" \
      description="Your self-hosted, globally interconnected microblogging community"

ARG UID=991
ARG GID=991

ENV PATH=/mastodon/bin:$PATH \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production \
    NODE_ENV=production

ARG YARN_VERSION=1.3.2
ARG YARN_DOWNLOAD_SHA256=6cfe82e530ef0837212f13e45c1565ba53f5199eec2527b85ecbcd88bf26821d
ARG LIBICONV_VERSION=1.15
ARG LIBICONV_DOWNLOAD_SHA256=ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178

EXPOSE 3000 4000

WORKDIR /mastodon

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    libicu-dev \
    libidn11-dev \
    libssl-dev \
    libgmp3-dev \
    libtool-bin \
    libpq-dev \
    libprotobuf-dev \
    protobuf-compiler \
    python \
    ca-certificates \
    ffmpeg \
    file \
    git \
    imagemagick \
    tzdata \
    gnupg \
 && wget -O - https://deb.nodesource.com/setup_8.x | bash - \
 && apt-get update \
 && apt-get install -y --no-install-recommends nodejs \
 && update-ca-certificates \
 && mkdir -p /tmp/src /opt \
 && wget -O yarn.tar.gz "https://github.com/yarnpkg/yarn/releases/download/v$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
 && echo "$YARN_DOWNLOAD_SHA256 *yarn.tar.gz" | sha256sum -c - \
 && tar -xzf yarn.tar.gz -C /tmp/src \
 && rm yarn.tar.gz \
 && mv /tmp/src/yarn-v$YARN_VERSION /opt/yarn \
 && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
 && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg \
 && wget -O libiconv.tar.gz "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$LIBICONV_VERSION.tar.gz" \
 && echo "$LIBICONV_DOWNLOAD_SHA256 *libiconv.tar.gz" | sha256sum -c - \
 && tar -xzf libiconv.tar.gz -C /tmp/src \
 && rm libiconv.tar.gz \
 && cd /tmp/src/libiconv-$LIBICONV_VERSION \
 && ./configure --prefix=/usr/local \
 && make -j$(getconf _NPROCESSORS_ONLN)\
 && make install \
 && libtool --finish /usr/local/lib \
 && cd /mastodon \
 && rm -rf /tmp/* /var/lib/apt/lists/*

ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

COPY Gemfile Gemfile.lock package.json yarn.lock .yarnclean /mastodon/

RUN bundle config build.nokogiri --with-iconv-lib=/usr/local/lib --with-iconv-include=/usr/local/include \
 && bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --without test development \
 && yarn --pure-lockfile \
 && yarn cache clean

RUN groupadd -g ${GID} mastodon && useradd -d /mastodon -s /bin/sh -g mastodon -u ${UID} mastodon \
 && mkdir -p /mastodon/public/system /mastodon/public/assets /mastodon/public/packs \
 && chown mastodon:mastodon /mastodon \
 && chown -R mastodon:mastodon /mastodon/public

COPY --chown=mastodon:mastodon . /mastodon

VOLUME /mastodon/public/system

USER mastodon

RUN OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile

ENTRYPOINT ["/sbin/tini", "--"]
