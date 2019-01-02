FROM ubuntu:18.04

ADD docker/tools/snore /snore

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get install -y git curl build-essential libreadline-dev libssl1.0-dev zlib1g-dev \
        graphicsmagick \
        libproj-dev libgeos-dev libgeos++-dev `#rgeo` \
        openjdk-8-jdk  `#rjb` \
        libqtwebkit-dev `#capybara` \
        libicu-dev `#charlock_holmes` \
        libpq-dev `#pq` \
        libreoffice && \
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv &&\
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    mkdir -p "$(rbenv root)"/plugins && \
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    echo 'export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"' >> ~/.bashrc && \
    source ~/.bashrc && \
    rbenv install 2.3.8 && rbenv global 2.3.8 && gem install bundler

