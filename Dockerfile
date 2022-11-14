ARG BASE_IMAGE=python:3.9-slim-bullseye
FROM ${BASE_IMAGE} as base

SHELL [ "/bin/bash", "-c" ]

FROM base as builder
RUN apt-get -qq -y update && \
    apt-get -qq -y install \
        gcc \
        g++ \
        zlibc \
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
    rm -rf /var/lib/apt-get/lists/*

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
      -DCMAKE_INSTALL_PREFIX=/usr/local \
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
      --prefix=/usr/local && \
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
    export PYTHON=$(which python) && \
    ./configure \
      --prefix=/usr/local \
      --enable-pyext=yes && \
    make -j$(($(nproc) - 1)) && \
    make check && \
    make install && \
    rm -rf /code

# Install PYTHIA
ARG PYTHIA_VERSION=8307
# PYTHON_VERSION already exists in the base image
RUN mkdir /code && \
    cd /code && \
    wget http://home.thep.lu.se/~torbjorn/pythia8/pythia${PYTHIA_VERSION}.tgz && \
    tar xvfz pythia${PYTHIA_VERSION}.tgz && \
    cd pythia${PYTHIA_VERSION} && \
    ./configure --help && \
    export PYTHON_MINOR_VERSION=${PYTHON_VERSION::-2} && \
    ./configure \
      --prefix=/usr/local \
      --arch=Linux \
      --cxx=g++ \
      --with-gzip \
      --with-hepmc2 \
      --with-lhapdf6 \
      --with-fastjet3 \
      --with-python-bin=/usr/local/bin \
      --with-python-lib=/usr/local/lib/python${PYTHON_MINOR_VERSION} \
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

# copy HepMC
COPY --from=builder /usr/local/lib/libHepMC* /usr/local/lib/
COPY --from=builder /usr/local/include/HepMC /usr/local/include/HepMC
COPY --from=builder /usr/local/share/HepMC /usr/local/share/HepMC

# copy LHAPDF
COPY --from=builder /usr/local/bin/lhapdf* /usr/local/bin/
COPY --from=builder /usr/local/lib/libLHAPDF* /usr/local/lib/
COPY --from=builder /usr/local/lib/python3.9/site-packages/*lhapdf* /usr/local/lib/python3.9/site-packages/
COPY --from=builder /usr/local/include/LHAPDF /usr/local/include/LHAPDF
COPY --from=builder /usr/local/share/LHAPDF /usr/local/share/LHAPDF

# copy FastJet
COPY --from=builder /usr/local/bin/fastjet-config /usr/local/bin/
COPY --from=builder /usr/local/lib/libfastjet* /usr/local/lib/
COPY --from=builder /usr/local/lib/python3.9/site-packages/*fastjet* /usr/local/lib/python3.9/site-packages/
COPY --from=builder /usr/local/lib/libsiscone* /usr/local/lib/
COPY --from=builder /usr/local/include/fastjet /usr/local/include/fastjet
COPY --from=builder /usr/local/include/siscone /usr/local/include/siscone

# copy PYTHIA
COPY --from=builder /usr/local/bin/pythia8-config /usr/local/bin/
COPY --from=builder /usr/local/lib/libpythia8* /usr/local/lib/
COPY --from=builder /usr/local/lib/pythia8.so /usr/local/lib/
COPY --from=builder /usr/local/include/Pythia8 /usr/local/include/Pythia8
COPY --from=builder /usr/local/include/Pythia8Plugins /usr/local/include/Pythia8Plugins
COPY --from=builder /usr/local/share/Pythia8 /usr/local/share/Pythia8

WORKDIR /home/data
ENV HOME /home

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PYTHONPATH=/usr/local/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV PYTHIA8DATA=/usr/local/share/Pythia8/xmldoc

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
