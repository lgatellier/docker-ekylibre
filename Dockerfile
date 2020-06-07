FROM ubuntu:16.04

ENV PATH=$PATH:/opt/rbenv/bin

# Installation des packkages requis
RUN apt-get update && \
    apt-get install -y imagemagick graphicsmagick tesseract-ocr tesseract-ocr-ara tesseract-ocr-jpn tesseract-ocr-fra tesseract-ocr-eng tesseract-ocr-spa pdftk libreoffice poppler-utils poppler-data ghostscript openjdk-8-jdk libicu55 redis-server postgresql-9.5-postgis-2.2 postgresql-contrib libcurl4-openssl-dev libgeos-dev libgeos++-dev libproj-dev libpq-dev libxml2-dev libxslt1-dev zlib1g-dev libicu-dev libqtwebkit-dev ruby-foreman \
    git build-essential libreadline-dev && \
    git clone https://github.com/sstephenson/rbenv.git /opt/rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git /opt/rbenv/plugins/ruby-build

# Installation de ruby
RUN apt-get install curl libncurses5-dev libncursesw5-dev&& \
    ln -s /opt/rbenv ~/.rbenv && \
    eval "$(rbenv init -)" && \
    rbenv install 2.3.8 && \
    rbenv global 2.3.8 && \
    rbenv rehash && \
    echo -n "Installed " && ruby -v

# Récupération des sources d'ekylibre
RUN git clone https://github.com/ekylibre/ekylibre.git /opt/ekylibre && \
    useradd -m ekylibre

# Variables d'environnement pour la connexion à la base de données
ENV EKYLIBRE_DATABASE_HOST db
ENV EKYLIBRE_DATABASE_PORT 5432
ENV EKYLIBRE_DATABASE_NAME ekylibre
ENV EKYLIBRE_DATABASE_USER ekylibre
ENV EKYLIBRE_DATABASE_PASSWORD ekylibre
 
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1
# Copie du fichier de configuration de la connexion à la base de données
COPY ekylibre/config/database.yml /opt/ekylibre/config

# Installation des paquets gems
WORKDIR /opt/ekylibre
RUN eval "$(rbenv init -)" && \
    gem install bundler -v '1.17.3' && \
    gem install pkg-config -v '~> 1.1.7' && \
    chown -R ekylibre /opt/ekylibre

USER root

RUN eval "$(rbenv init -)" && \
    bundle install

COPY docker-entrypoint.sh /opt

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get install apt-transport-https && \
    curl -sS https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && apt-get install -y nodejs yarn && \
    yarn install --check-files && \
    chmod +x /opt/docker-entrypoint.sh

CMD /opt/docker-entrypoint.sh

