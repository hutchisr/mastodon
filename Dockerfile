FROM ruby:2.4.1-alpine

LABEL maintainer="https://github.com/rainyday/mastodon" \
      description="An actually GNU Social-compatible microblogging server"

ENV RAILS_ENV=production \
    NODE_ENV=production

EXPOSE 3000 4000

WORKDIR /mastodon

COPY Gemfile Gemfile.lock package.json yarn.lock /mastodon/

RUN BUILD_DEPS=" \
    postgresql-dev \
    libxml2-dev \
    libxslt-dev \
    python \
    build-base" \
 && echo -e '@edge http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
 && apk -U upgrade && apk add \
    $BUILD_DEPS \
    nodejs \
    yarn@edge \
    libpq \
    libxml2 \
    libxslt \
    ffmpeg \
    file \
    imagemagick@edge \
 && bundle install --deployment --without test development \
 && yarn --ignore-optional \
 && yarn cache clean \
 && npm -g cache clean \
 && apk del $BUILD_DEPS \
 && rm -rf /tmp/* /var/cache/apk/*

COPY . /mastodon

VOLUME /mastodon/public
