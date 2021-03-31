FROM alpine:latest

# Developer tools
RUN apk update && apk upgrade && apk add \
  autoconf \
  automake \
  bash \
  binutils \
  curl \
  curl-dev \
  gcc \
  git \
  libtool \
  linux-headers \
  make \
  musl-dev \
  zip

# Build osslsigndata
RUN { \
    VERSION=1.1.1k && \
    cd && \
    curl --silent --show-error https://www.openssl.org/source/openssl-"$VERSION".tar.gz -o openssl-"$VERSION".tar.gz && \
    tar xzvf openssl-"$VERSION".tar.gz && \
    mv openssl-"$VERSION" openssl && \
    cd openssl && \
    CC='gcc -fvisibility=hidden' && \
    ./Configure --prefix=/usr/local --openssldir=/etc/ssl no-shared linux-x86_64 && \
    make && \
    make install; \
  }

ADD . /osslsigndata
WORKDIR /osslsigndata
RUN { \
    export OPENSSL_CFLAGS="-I/usr/local/include" && \
    export OPENSSL_LIBS="-L/usr/local/lib -lcrypto" && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install; \
    rm -rf /osslsigndata; \
  }
