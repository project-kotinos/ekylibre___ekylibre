# IMAGE: ekylibre/ruby-base
FROM ubuntu:18.04

SHELL ["/bin/bash", "-lc"]

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get install -y git curl build-essential libreadline-dev libssl1.0-dev zlib1g-dev \
        graphicsmagick \
        libproj-dev libgeos-dev libgeos++-dev `#rgeo` \
        openjdk-8-jdk  `#rjb` \
        libicu-dev `#charlock_holmes` \
        libpq-dev `#pq` \
        libreoffice

RUN git clone https://github.com/rbenv/rbenv.git /rbenv && \
    echo 'export RBENV_ROOT=/rbenv' >> /etc/profile.d/rbenv.sh && \
    echo 'export PATH="/rbenv/bin:$PATH"' >> /etc/profile.d/rbenv.sh && \
    echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build && \
    rbenv install 2.3.8 && \
    rbenv global 2.3.8 && \
    gem install bundler

RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /etc/profile.d/java_home.sh
