# IMAGE: ekylibre/ekylibre-dev
FROM ekylibre/ruby-base:2.3.8
ENV U_UID=1000 U_GID=1000 U_NAME=ekylibre U_GNAME=ekylibre

SHELL ["/bin/bash", "-lc"]

RUN apt-get update && \
    apt-get -y install \
        libqtwebkit-dev `#capybara`

RUN groupadd -g $U_GID $U_GNAME && \
    useradd -g $U_GID -u $U_UID -m -s /bin/bash $U_NAME && \
    mkdir /ekylibre && \
    chown -R $U_UID:$U_GID /rbenv /ekylibre

ADD docker/tools/snore /bin/snore

USER $U_NAME
WORKDIR /ekylibre
ADD Gemfile Gemfile.lock ./
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
    . "$HOME/.nvm/nvm.sh" && \
    nvm install --lts=dubnium && \
    npm i -g yarn && \
    bundle install

VOLUME /rbenv/versions/$RUBY_VERSION/lib/ruby/gems
VOLUME /ekylibre
EXPOSE 3000
USER root
RUN echo "Europe/Paris" > /etc/timezone
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

USER $U_NAME
