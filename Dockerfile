FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV HOME="/config"

RUN \
 apt-get update && \
 apt-get install -y \
 	php7.2-cli \
 	php7.2-curl \
	php7.2-xml \
	php7.2-zip \
	git \
	nano \
	net-tools \
	sudo && \
 echo "**** install code-server ****" && \
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

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# CleanUp
RUN  rm -rf tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN composer global require "squizlabs/php_codesniffer=*" && \
 	composer global require friendsofphp/php-cs-fixer && \
 	composer global require phpmd/phpmd

# add local files
COPY /root /

# ports and volumes
EXPOSE 8443
