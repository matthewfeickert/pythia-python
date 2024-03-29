FROM matthewfeickert/pythia-python:pythia8.308

SHELL [ "/bin/bash", "-c" ]
ENV PATH=/usr/local/venv/bin:"${PATH}"

# Remove existing non-root user "docker" with uid 1000
# to avoid conflict with jovyan
USER root
RUN deluser docker

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

USER root
RUN adduser \
      --shell /bin/bash \
      --gecos "Default user" \
      --uid ${NB_UID} \
      --disabled-password \
      ${NB_USER}
USER ${NB_USER}

# FIXME: Downgrade jupyter-server to contend with:
# https://github.com/jupyterhub/repo2docker/issues/1231
# https://github.com/jupyter-server/jupyter_server/issues/1038
RUN python -m pip --no-cache-dir install --upgrade \
    notebook \
    jupyterlab \
    jupyterhub \
    'jupyter-server<2.0.0' \
    matplotlib \
    ipympl \
    jupytext

# Make sure the contents of the repo are in ${HOME} and that
# NB_UID owns all files it should control
COPY . ${HOME}
USER root
RUN find "${HOME}/examples" -type f -iname "*.py" | xargs jupytext --to notebook && \
    chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
WORKDIR ${HOME}

# Null out ENTRYPOINT and CMD to let repo2docker control them
ENTRYPOINT [ ]
CMD [ ]
