FROM python:3.7-slim as base

FROM base as builder
RUN apt-get -qq -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y install \
        gcc \
        g++ \
        zlibc \
        zlib1g-dev \
        libbz2-dev \
        wget \
        make \
        python3-dev \
        sudo && \
        apt-get -y autoclean && \
        apt-get -y autoremove && \
        rm -rf /var/lib/apt-get/lists/*

ENV PYTHIA_VERSION=8301
ENV PYTHON_VERSION=3.7

# In Python 8.301 the --prefix option is broken, so cp is used to install software
RUN mkdir /code && \
    cd /code && \
    wget http://home.thep.lu.se/~torbjorn/pythia8/pythia${PYTHIA_VERSION}.tgz && \
    tar xvfz pythia${PYTHIA_VERSION}.tgz && \
    cd pythia${PYTHIA_VERSION} && \
    ./configure --help && \
    ./configure \
      --prefix=/usr/local \
      --arch=Linux \
      --cxx=g++ \
      --with-gzip \
      --with-python-bin=/usr/local/bin \
      --with-python-lib=/usr/lib/python${PYTHON_VERSION} \
      --with-python-include=/usr/include/python${PYTHON_VERSION} && \
    make && \
    cp -r /code/pythia8301/lib/* /usr/local/lib/ && \
    cp -r /code/pythia8301/share/* /usr/local/share/
ENV PYTHONPATH=/usr/local/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

ENTRYPOINT /bin/bash
