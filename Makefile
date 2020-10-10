default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--build-arg BASE_IMAGE=python:3.8-slim \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg LHAPDF_VERSION=6.3.0 \
	--build-arg FASTJET_VERSION=3.3.4 \
	--build-arg PYTHIA_VERSION=8303 \
	--tag matthewfeickert/pythia-python:pythia8.303 \
	--tag matthewfeickert/pythia-python:pythia8.303-hepmc2.06.11-fastjet3.3.4-python3.8 \
	--tag matthewfeickert/pythia-python:latest

run:
	docker run --rm -it matthewfeickert/pythia-python:latest

test:
	docker run \
		--rm \
		-v $(shell pwd):$(shell pwd) \
		-w $(shell pwd) \
		matthewfeickert/pythia-python:latest \
		"g++ tests/main01.cc -o tests/main01 -lpythia8 -ldl; ./tests/main01 > main01_out_cpp.txt"
	wc main01_out_cpp.txt
	docker run \
		--rm \
		-v $(shell pwd):$(shell pwd) \
		-w $(shell pwd) \
		matthewfeickert/pythia-python:latest \
		"python tests/main01.py > main01_out_py.txt"
	wc main01_out_py.txt

test_hepmc:
	docker run \
		--rm \
		-v $(shell pwd):$(shell pwd) \
		-w $(shell pwd) \
		matthewfeickert/pythia-python:latest \
		"g++ tests/main42.cc -o tests/main42 -lpythia8 -lHepMC -ldl; ./tests/main42 tests/main42.cmnd main42_out.hepmc"
