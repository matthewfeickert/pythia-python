default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--cache-from matthewfeickert/pythia-python:latest \
	--tag matthewfeickert/pythia-python:pythia8.3-python3.7 \
	--tag matthewfeickert/pythia-python:pythia8.301-python3.7 \
	--tag matthewfeickert/pythia-python:latest

run:
	docker run --rm -it matthewfeickert/pythia-python:latest
