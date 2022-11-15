default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--build-arg BASE_IMAGE=python:3.9-slim-bullseye \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg LHAPDF_VERSION=6.5.3 \
	--build-arg FASTJET_VERSION=3.4.0 \
	--build-arg PYTHIA_VERSION=8307 \
	--tag matthewfeickert/pythia-python:pythia8.307 \
	--tag matthewfeickert/pythia-python:pythia8.307-hepmc2.06.11-fastjet3.4.0-python3.9 \
	--tag matthewfeickert/pythia-python:latest

run:
	docker run --rm -it matthewfeickert/pythia-python:latest

test:
	docker run \
		--rm \
		-v $(shell pwd):$(shell pwd) \
		-w $(shell pwd) \
		matthewfeickert/pythia-python:latest \
		'g++ tests/main01.cc -pthread -o tests/main01 $$(pythia8-config --cxxflags --ldflags); ./tests/main01 > main01_out_cpp.txt'
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
		'g++ tests/main42.cc -pthread -o tests/main42 $$(pythia8-config --cxxflags --ldflags) -lHepMC; ./tests/main42 tests/main42.cmnd main42_out.hepmc'

test_fastjet:
	docker run \
		--rm \
		-v $(shell pwd):$(shell pwd) \
		-w $(shell pwd) \
		matthewfeickert/pythia-python:latest \
        'g++ tests/test_FastJet.cc -o tests/test_FastJet $$(/usr/local/venv/bin/fastjet-config --cxxflags --libs --plugins); ./tests/test_FastJet'
