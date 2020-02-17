#ARG PYTHON_VERSION=3.7
#FROM python:${PYTHON_VERSION}-slim as base
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

ARG PYTHIA_VERSION=8301
#ENV PYTHIA_VERSION=8301
ENV PYTHON_VERSION=3.7

# In PYTHIA 8.301 the --prefix option is broken, so cp is used to install software
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
    make -j4 && \
    cp -r /code/pythia${PYTHIA_VERSION}/bin/* /usr/local/bin/ && \
    cp -r /code/pythia${PYTHIA_VERSION}/lib/* /usr/local/lib/ && \
    cp -r /code/pythia${PYTHIA_VERSION}/include/* /usr/local/include/ && \
    cp -r /code/pythia${PYTHIA_VERSION}/share/* /usr/local/share/ && \
    rm -rf /code

FROM base
# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PYTHONPATH=/usr/local/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /usr/local/share /usr/local/share

# Create user "docker" with sudo powers
RUN useradd -m docker && \
    usermod -aG sudo docker && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    cp /root/.bashrc /home/docker/ && \
    mkdir /home/docker/data && \
    chown -R --from=root docker /home/docker

WORKDIR /home/docker/data
ENV HOME /home/docker
ENV USER docker
USER docker
ENV PATH /home/docker/.local/bin:$PATH

ENTRYPOINT ["/bin/bash"]
