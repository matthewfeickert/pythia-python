FROM python:3.7-slim as base

FROM base as builder
RUN apt-get -qq -y update && \
    apt-get -qq -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y install \
        gcc \
        g++ \
        wget \
        make \
        python3-dev \
        sudo && \
        apt-get -y autoclean && \
        apt-get -y autoremove && \
        rm -rf /var/lib/apt-get/lists/*

RUN python3 -m pip install --upgrade --no-cache-dir pip setuptools wheel

ENV PYTHIA_VERSION=8301

RUN mkdir /code && \
    cd /code && \
    wget http://home.thep.lu.se/~torbjorn/pythia8/pythia${PYTHIA_VERSION}.tgz && \
    tar xvfz pythia${PYTHIA_VERSION}.tgz && \
    cd pythia${PYTHIA_VERSION} && \
    CXX=g++ ./configure \
      --prefix=/usr/local \
      --arch=Linux \
      --with-python --with-python-include=$(which python3) && \
    make
