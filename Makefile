default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--cache-from matthewfeickert/pythia-python:latest \
	--build-arg PYTHON_VERSION=3.7 \
	--build-arg PYTHIA_VERSION=8301 \
	--tag matthewfeickert/pythia-python:pythia8.3-python3.7 \
	--tag matthewfeickert/pythia-python:pythia8.301-python3.7 \
	--tag matthewfeickert/pythia-python:latest

run:
	docker run --rm -it matthewfeickert/pythia-python:latest

test:
	docker run \
		--rm \
		-v $(shell pwd):$(shell pwd) \
		-w $(shell pwd) \
		matthewfeickert/pythia-python:latest \
		-c "python tests/main01.py > main01_out.txt"
