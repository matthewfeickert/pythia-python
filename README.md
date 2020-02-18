# PYTHIA 8 Docker image with Python 3

> PYTHIA is a program for the generation of high-energy physics events, i.e. for the description of collisions at high energies between elementary particles such as e+, e-, p and pbar in various combinations.

`PYTHIA` 8's source is [distributed on GitLab](https://gitlab.com/Pythia8/releases) and is a product of the [`PYTHIA` development team](http://home.thep.lu.se/~torbjorn/Pythia.html).

## Installation

- Check the [list of available tags on Docker Hub](https://hub.docker.com/r/matthewfeickert/pythia-python/tags?page=1) to find the tag you want.
- Use `docker pull` to pull down the image corresponding to the tag. For example:

```
docker pull matthewfeickert/pythia-python:pythia8.301-python3.7
```

## Use

You can either use the image as "`PYTHIA` as a service", as demoed here with the test script in the repo using the Python bindings

```
docker run --rm -v $PWD:$PWD -w $PWD matthewfeickert/pythia-python:pythia8.301-python3.7 \
  -c "python tests/main01.py > main01_out_py.txt"
```

or the original C++

```
docker run --rm -v $PWD:$PWD -w $PWD matthewfeickert/pythia-python:pythia8.301-python3.7 \
  -c "g++ tests/main01.cc -o tests/main01 -lpythia8 -ldl; ./tests/main01 > main01_out_cpp.txt"
```

or you can run interactively

```
docker run --rm -it matthewfeickert/pythia-python:latest
```
