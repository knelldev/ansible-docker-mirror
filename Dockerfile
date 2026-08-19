# Dockerfile for 0.10
ARG BASE_IMAGE=python-slim
ARG BASE_IMAGE_TAG=3-bullseye
FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

# envs
ENV ANSIBLE_HOME=/ansible
ENV ANSIBLE_CONFIG=/ansible/ansible.cfg

# prepare nonroot user
RUN adduser --uid 1000 --disabled-password --gecos "" ansible

# prepare ansible folder
RUN mkdir -p /ansible && \
  chown -R ansible: /ansible

# install pip packsges
COPY --chown=ansible requirements.txt /ansible/requirements.txt
RUN pip3 install --no-cache-dir -r /ansible/requirements.txt

# copy ansible files
COPY --chown=ansible . /ansible

# switch user to nonroot user
USER 1000
