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
	--build-arg PYTHIA_VERSION=8307 \
	--tag matthewfeickert/pythia-python:pythia8.308 \
	--tag matthewfeickert/pythia-python:latest \
	--push \
	.
	docker buildx stop buildx_builder
	docker buildx rm buildx_builder

image:
	docker buildx build . \
	--file Dockerfile \
	--build-arg BASE_IMAGE=python:3.10-slim-bullseye \
	--build-arg HEPMC_VERSION=3.2.5 \
	--build-arg LHAPDF_VERSION=6.5.3 \
	--build-arg FASTJET_VERSION=3.4.0 \
	--build-arg PYTHIA_VERSION=8308 \
	--tag matthewfeickert/pythia-python:pythia8.308 \
	--tag matthewfeickert/pythia-python:pythia8.308-hepmc3.2.5-fastjet3.4.0-python3.10 \
	--tag matthewfeickert/pythia-python:latest

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

test_hepmc3:
	docker run \
		--rm \
		--user $(shell id --user $(USER)):$(shell id --group) \
		--volume $(shell pwd):/work \
		matthewfeickert/pythia-python:latest \
		'g++ tests/main300.cc -pthread -o tests/main300 $$(pythia8-config --cxxflags --ldflags) -lHepMC3; ./tests/main300 --input main300.cmnd --hepmc_output main300.hepmc'

test_fastjet:
	docker run \
		--rm \
		--user $(shell id --user $(USER)):$(shell id --group) \
		--volume $(shell pwd):/work \
		matthewfeickert/pythia-python:latest \
        'g++ tests/test_FastJet.cc -o tests/test_FastJet $$(fastjet-config --cxxflags --libs --plugins); ./tests/test_FastJet'

binder_repo2docker:
	repo2docker \
	--image-name matthewfeickert/pythia-python:binder \
	.
