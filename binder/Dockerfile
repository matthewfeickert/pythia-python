# c.f. https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html#preparing-your-dockerfile
FROM matthewfeickert/pythia-python:pythia8.308

# Remove exisiting non-root user "docker" with uid 1000
# to avoid conflict with jovyan
USER root
RUN deluser docker

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

USER root
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
USER ${NB_USER}

# Make sure the contents of the repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME} && \
    chown -R ${NB_UID} /usr/local/venv
USER ${NB_USER}
WORKDIR ${HOME}

# Install necessary jupyter dependencies
# Install jupyterhub to allow use of the repository with an authenticated Binder
RUN python -m pip install --no-cache-dir jupyter jupyterlab jupyterhub

ENTRYPOINT [ ]
CMD [ ]


# Stuck on getting things working with no password
# https://jupyter-notebook.readthedocs.io/en/stable/public_server.html
# docker build --file binder/Dockerfile -t matthewfeickert/pythia-python:binder .

# FAIL:
# docker run -it --rm -p 8888:8888 matthewfeickert/pythia-python:binder jupyter notebook --NotebookApp.default_url=/lab/ --ip=0.0.0.0 --port=8888

# PASS:
# docker run -it --rm -p 8888:8888 matthewfeickert/pythia-python:binder jupyter lab --NotebookApp.default_url=/lab/ --ip=0.0.0.0 --port=8888

# PASS:
# docker run -it --rm -p 8888:8888 matthewfeickert/pythia-python:binder jupyter lab --NotebookApp.default_url=/lab/ --ip=0.0.0.0 --port=8888

# PASS:
# docker run -it --rm -p 8888:8888 matthewfeickert/pythia-python:binder jupyter notebook --ip=0.0.0.0 --port=8888

# FAIL:
# repo2docker .
