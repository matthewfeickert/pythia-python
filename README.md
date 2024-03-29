# PYTHIA 8 Docker image with Python 3 and HEP simulation stack

[![Docker Pulls](https://img.shields.io/docker/pulls/matthewfeickert/pythia-python)](https://hub.docker.com/r/matthewfeickert/pythia-python)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/matthewfeickert/pythia-python/latest)](https://hub.docker.com/r/matthewfeickert/pythia-python/tags?name=latest)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/matthewfeickert/pythia-python/HEAD)

> PYTHIA is a program for the generation of high-energy physics events, i.e. for the description of collisions at high energies between elementary particles such as e+, e-, p and pbar in various combinations.

`PYTHIA` 8's source is [distributed on GitLab](https://gitlab.com/Pythia8/releases) and is a product of the [`PYTHIA` development team](https://pythia.org/).

## Distributed Software

The Docker image contains:

* Python 3.10
* [HepMC3](http://hepmc.web.cern.ch/hepmc/) `v3.2.5`
* [LHAPDF](https://lhapdf.hepforge.org/) `v6.5.3`
* [FastJet](http://fastjet.fr/) `v3.4.0`
* [PYTHIA](https://pythia.org/) `v8.308`

## Installation

- Check the [list of available tags on Docker Hub](https://hub.docker.com/r/matthewfeickert/pythia-python/tags?page=1) to find the tag you want.
- Use `docker pull` to pull down the image corresponding to the tag. For example:

```
docker pull matthewfeickert/pythia-python:pythia8.308
```

## Use

You can either use the image as "`PYTHIA` as a service", as demoed here with the test script in the repo using the Python bindings

```
docker run \
  --rm \
  --user $(id -u $USER):$(id -g $USER) \
  --volume $PWD:/home/docker/work \
  matthewfeickert/pythia-python:pythia8.308 \
  'python tests/main01.py > main01_out_py.txt'
```

or the original C++

```
docker run \
  --rm \
  --user $(id -u $USER):$(id -g $USER) \
  --volume $PWD:/home/docker/work \
  matthewfeickert/pythia-python:pythia8.308 \
  'g++ tests/main01.cc -pthread -o tests/main01 $(pythia8-config --cxxflags --ldflags); ./tests/main01 > main01_out_cpp.txt'
```

or you can run interactively

```
docker run \
  --rm \
  -ti \
  --publish 8888:8888 \
  --user $(id -u $USER):$(id -g $USER) \
  --volume $PWD:/home/docker/work \
  matthewfeickert/pythia-python:pythia8.308
```
