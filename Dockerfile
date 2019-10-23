FROM lsiobase/ubuntu:bionic
# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Cheycron"
# environment settings
ENV HOME="/config"

RUN echo "======[Base Requerimients Install]======" && \
 apt-get update && \
 apt-get install -y \
 	php7.2-cli \
 	php7.2-curl \
	php7.2-xml \
	php7.2-zip \
	git \
	nano \
	npm \
	net-tools \
	sudo

RUN echo "======[Install code-server]======" && \
 if [ -z ${CODE_RELEASE+x} ]; then \
	CODE_RELEASE=$(curl -sX GET "https://api.github.com/repos/cdr/code-server/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/code.tar.gz -L \
	"https://github.com/cdr/code-server/releases/download/${CODE_RELEASE}/code-server${CODE_RELEASE}-linux-x64.tar.gz" && \
 tar xzf /tmp/code.tar.gz -C \
	/usr/bin/ --strip-components=1 \
  --wildcards code-server*/code-server

# Install composer && tools
RUN echo "======[Install Composer & Tools]======" && \
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
	composer global require "squizlabs/php_codesniffer=*" && \
 	composer global require friendsofphp/php-cs-fixer && \
 	composer global require phpmd/phpmd && \
	composer global require phpstan/phpstan && \
	composer global require deployer/deployer && \
	composer global require escapestudios/symfony2-coding-standard && \
	composer global require phpunit/phpunit

RUN RUN echo "======[Install NPM Tools]======" && \
	npm install -g prettier && \
	npm install -g @prettier/plugin-php
	
# CleanUp
RUN  rm -rf tmp/* /var/lib/apt/lists/* /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 8443
