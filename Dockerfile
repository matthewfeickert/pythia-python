ARG BASE_IMAGE=python:3.10-slim-bullseye
FROM ${BASE_IMAGE} as base

ARG TARGETARCH

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
      curl \
      make \
      cmake \
      rsync \
      libboost-all-dev && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    python -m venv /usr/local/venv && \
    . /usr/local/venv/bin/activate && \
    python -m pip --no-cache-dir install --upgrade pip setuptools wheel && \
    python -m pip list

# Install HepMC
ARG HEPMC_VERSION=3.2.5
RUN mkdir /code && \
    cd /code && \
    wget https://hepmc.web.cern.ch/hepmc/releases/HepMC3-${HEPMC_VERSION}.tar.gz && \
    tar xvfz HepMC3-${HEPMC_VERSION}.tar.gz && \
    mv HepMC3-${HEPMC_VERSION} src && \
    cmake \
      -DCMAKE_CXX_COMPILER=$(command -v g++) \
      -DCMAKE_BUILD_TYPE=Release \
      -DHEPMC3_ENABLE_ROOTIO=OFF \
      -DHEPMC3_ENABLE_PYTHON=ON \
      -DHEPMC3_PYTHON_VERSIONS=3.X \
      -DHEPMC3_ENABLE_TEST=ON \
      -DCMAKE_INSTALL_PREFIX=/usr/local/venv \
      -S src \
      -B build && \
    cmake build -L && \
    cmake --build build --parallel $(nproc --ignore=1) && \
    cmake --build build --target install && \
    rm -rf /code

# Install LHAPDF
ARG LHAPDF_VERSION=6.5.3
RUN mkdir /code && \
    cd /code && \
    wget https://lhapdf.hepforge.org/downloads/?f=LHAPDF-${LHAPDF_VERSION}.tar.gz -O LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    tar xvfz LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    cd LHAPDF-${LHAPDF_VERSION} && \
    ./configure --help && \
    export CXX=$(command -v g++) && \
    export PYTHON=$(command -v python) && \
    ./configure \
      --prefix=/usr/local/venv && \
    make -j$(nproc --ignore=1) && \
    make check && \
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
    export CXX=$(command -v g++) && \
    ./configure \
      --prefix=/usr/local/venv && \
    make -j$(nproc --ignore=1) && \
    make check && \
    make install && \
    python -m pip --no-cache-dir install "fastjet~=${FASTJET_VERSION}.0" && \
    rm -rf /code

# Install PYTHIA
ARG PYTHIA_VERSION=8308
# PYTHON_VERSION already exists in the base image
RUN mkdir /code && \
    cd /code && \
    wget --quiet "https://pythia.org/download/pythia${PYTHIA_VERSION:0:2}/pythia${PYTHIA_VERSION}.tgz" && \
    tar xvfz pythia${PYTHIA_VERSION}.tgz && \
    cd pythia${PYTHIA_VERSION} && \
    ./configure --help && \
    export PYTHON_MINOR_VERSION="${PYTHON_VERSION%.*}" && \
    if [[ "${TARGETARCH}" == "amd64" ]]; then \
        export CXX_COMMON="-O2 -m64 -pedantic -W -Wall -Wshadow -fPIC -std=c++17"; \
    elif [[ "${TARGETARCH}" == "arm64" ]]; then \
        export CXX_COMMON="-O2 -pedantic -W -Wall -Wshadow -fPIC -std=c++17"; \
    else \
      echo "TARGETARCH ${TARGETARCH} not supported. Exiting now."; \
      exit -1; \
    fi && \
    ./configure \
      --prefix=/usr/local/venv \
      --arch=Linux \
      --cxx=g++ \
      --enable-64bit \
      --with-gzip \
      --with-hepmc3=/usr/local/venv \
      --with-lhapdf6=/usr/local/venv \
      --with-fastjet3=/usr/local/venv \
      --with-python-bin=/usr/local/venv/bin/ \
      --with-python-lib=/usr/local/venv/lib/python${PYTHON_MINOR_VERSION} \
      --with-python-include=/usr/local/include/python${PYTHON_MINOR_VERSION} \
      --cxx-common="${CXX_COMMON}" \
      --cxx-shared="-shared -std=c++17" && \
    make --jobs $(nproc --ignore=1) && \
    make install && \
    unset CXX_COMMON && \
    rm -rf /code

FROM base

SHELL [ "/bin/bash", "-c" ]
ENV PATH=/usr/local/venv/bin:"${PATH}"

# Install any packages needed by default user
RUN apt-get -qq -y update && \
    apt-get -qq -y install --no-install-recommends \
      gcc \
      g++ \
      zlib1g \
      zlib1g-dev \
      libbz2-dev \
      wget \
      curl \
      git \
      make \
      cmake \
      rsync \
      libboost-all-dev \
      vim \
      emacs && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user "docker" with uid 1000
RUN adduser \
      --shell /bin/bash \
      --gecos "default user" \
      --uid 1000 \
      --disabled-password \
      docker && \
    chown -R docker /home/docker && \
    mkdir -p /home/docker/work && \
    chown -R docker /home/docker/work && \
    mkdir /work && \
    chown -R docker /work && \
    chmod -R 777 /work && \
    printf '\nexport PATH=/usr/local/venv/bin:"${PATH}"\n' >> /root/.bashrc && \
    cp /root/.bashrc /etc/.bashrc && \
    echo 'if [ -f /etc/.bashrc ]; then . /etc/.bashrc; fi' >> /etc/profile && \
    echo "SHELL=/bin/bash" >> /etc/environment

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PYTHONPATH=/usr/local/venv/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/venv/lib:$LD_LIBRARY_PATH
ENV PYTHIA8DATA=/usr/local/venv/share/Pythia8/xmldoc

ENV PATH=/home/docker/.local/bin:"${PATH}"

COPY --from=builder --chown=docker --chmod=777 /usr/local/venv /usr/local/venv

USER docker

ENV USER ${USER}
ENV HOME /home/docker
WORKDIR ${HOME}/work

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
