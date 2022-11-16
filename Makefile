default: image

all: image

multi_platform:
	docker pull python:3.9-slim-bullseye
	docker buildx create \
		--name buildx_builder \
		--driver docker-container \
		--bootstrap \
		--use
	docker buildx build \
	--file Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--build-arg BASE_IMAGE=python:3.9-slim-bullseye \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg LHAPDF_VERSION=6.5.3 \
	--build-arg FASTJET_VERSION=3.4.0 \
	--build-arg PYTHIA_VERSION=8245 \
	--tag matthewfeickert/pythia-python:pythia8.245 \
	--push \
	.
	docker buildx stop buildx_builder
	docker buildx rm buildx_builder

image:
	docker buildx build . \
	--file Dockerfile \
	--build-arg BASE_IMAGE=python:3.9-slim-bullseye \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg LHAPDF_VERSION=6.5.3 \
	--build-arg FASTJET_VERSION=3.4.0 \
	--build-arg PYTHIA_VERSION=8245 \
	--tag matthewfeickert/pythia-python:pythia8.245 \
	--tag matthewfeickert/pythia-python:pythia8.245-hepmc2.06.11-fastjet3.4.0-python3.9 \
	--tag matthewfeickert/pythia-python:local-latest

run:
	docker run --rm -it matthewfeickert/pythia-python:latest

test:
	docker run \
		--rm \
		--user $(shell id --user $(USER)):$(shell id --group) \
		--volume $(shell pwd):/work \
		matthewfeickert/pythia-python:latest \
		'g++ tests/main01.cc -pthread -o tests/main01 $$(pythia8-config --cxxflags --ldflags); ./tests/main01 > main01_out_cpp.txt'
	wc main01_out_cpp.txt
	docker run \
		--rm \
		--user $(shell id --user $(USER)):$(shell id --group) \
		--volume $(shell pwd):/work \
		matthewfeickert/pythia-python:latest \
		"python tests/main01.py > main01_out_py.txt"
	wc main01_out_py.txt

test_hepmc:
	docker run \
		--rm \
		--user $(shell id --user $(USER)):$(shell id --group) \
		--volume $(shell pwd):/work \
		matthewfeickert/pythia-python:latest \
		'g++ tests/main42.cc -pthread -o tests/main42 $$(pythia8-config --cxxflags --ldflags) -lHepMC; ./tests/main42 tests/main42.cmnd main42_out.hepmc'

test_fastjet:
	docker run \
		--rm \
		--user $(shell id --user $(USER)):$(shell id --group) \
		--volume $(shell pwd):/work \
		matthewfeickert/pythia-python:latest \
        'g++ tests/test_FastJet.cc -o tests/test_FastJet $$(fastjet-config --cxxflags --libs --plugins); ./tests/test_FastJet'
