ARG BASE_IMAGE=python:3.9-slim-bullseye
FROM ${BASE_IMAGE} as base

SHELL [ "/bin/bash", "-c" ]

FROM base as builder

# Set PATH to pickup virtualenv by default
ENV PATH=/usr/local/venv/bin:"${PATH}"
RUN apt-get -qq -y update && \
    apt-get -qq -y install \
      gcc \
      g++ \
      zlib1g \
      zlib1g-dev \
      libbz2-dev \
      wget \
      make \
      cmake \
      rsync \
      python3-dev \
      sudo && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    python -m venv /usr/local/venv && \
    . /usr/local/venv/bin/activate && \
    python -m pip --no-cache-dir install pip setuptools wheel && \
    python -m pip list

# Install HepMC
ARG HEPMC_VERSION=2.06.11
RUN mkdir /code && \
    cd /code && \
    wget http://hepmc.web.cern.ch/hepmc/releases/hepmc${HEPMC_VERSION}.tgz && \
    tar xvfz hepmc${HEPMC_VERSION}.tgz && \
    mv HepMC-${HEPMC_VERSION} src && \
    mkdir build && \
    cd build && \
    cmake \
      -DCMAKE_CXX_COMPILER=$(which g++) \
      -DCMAKE_BUILD_TYPE=Release \
      -Dbuild_docs:BOOL=OFF \
      -Dmomentum:STRING=MEV \
      -Dlength:STRING=MM \
      -DCMAKE_INSTALL_PREFIX=/usr/local/venv \
      ../src && \
    cmake --build . -- -j$(($(nproc) - 1)) && \
    cmake --build . --target install && \
    rm -rf /code

# Install LHAPDF
ARG LHAPDF_VERSION=6.5.3
RUN mkdir /code && \
    cd /code && \
    wget https://lhapdf.hepforge.org/downloads/?f=LHAPDF-${LHAPDF_VERSION}.tar.gz -O LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    tar xvfz LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    cd LHAPDF-${LHAPDF_VERSION} && \
    ./configure --help && \
    export CXX=$(which g++) && \
    export PYTHON=$(which python) && \
    ./configure \
      --prefix=/usr/local/venv && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

# Install FastJet
ARG FASTJET_VERSION=3.4.0
RUN mkdir /code && \
    cd /code && \
    wget http://fastjet.fr/repo/fastjet-${FASTJET_VERSION}.tar.gz && \
    tar xvfz fastjet-${FASTJET_VERSION}.tar.gz && \
    cd fastjet-${FASTJET_VERSION} && \
    ./configure --help && \
    export CXX=$(which g++) && \
    export PYTHON=$(command -v python) && \
    export PYTHON_CONFIG=$(find /usr/local/ -iname "python-config.py") && \
    ./configure \
      --prefix=/usr/local/venv \
      --enable-pyext=yes && \
    make -j$(nproc --ignore=1) && \
    make check && \
    make install && \
    rm -rf /code

# Install PYTHIA
ARG PYTHIA_VERSION=8307
# PYTHON_VERSION already exists in the base image
RUN mkdir /code && \
    cd /code && \
    wget --quiet "https://pythia.org/download/pythia${PYTHIA_VERSION:0:2}/pythia${PYTHIA_VERSION}.tgz" && \
    tar xvfz pythia${PYTHIA_VERSION}.tgz && \
    cd pythia${PYTHIA_VERSION} && \
    ./configure --help && \
    export PYTHON_MINOR_VERSION=${PYTHON_VERSION::3} && \
    ./configure \
      --prefix=/usr/local \
      --arch=Linux \
      --cxx=g++ \
      --with-gzip \
      --with-hepmc2=/usr/local/venv \
      --with-lhapdf6=/usr/local/venv \
      --with-fastjet3=/usr/local/venv \
      --with-python-bin=/usr/local/venv/bin/ \
      --with-python-lib=/usr/local/venv/lib/python${PYTHON_MINOR_VERSION} \
      --with-python-include=/usr/local/include/python${PYTHON_MINOR_VERSION} && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

FROM base
RUN apt-get -qq -y update && \
    apt-get -qq -y install \
        g++ \
        make && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt-get/lists/*

# copy from builder
COPY --from=builder /usr/local/venv /usr/local/venv

WORKDIR /home/data
ENV HOME /home

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PYTHONPATH=/usr/local/venv/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/venv/lib:$LD_LIBRARY_PATH
ENV PYTHIA8DATA=/usr/local/venv/share/Pythia8/xmldoc

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
