#!/bin/bash

docker build -t portchaw/dind-node-rethinkdb-build-runner . && \
  NODE_VER=$(docker run --rm --privileged portchaw/dind-node-rethink-build-runner node --version) && \
  IMAGE_TAG=${NODE_VER#"v"} && \
  docker tag portchaw/dind-node-rethinkdb-build-runner portchaw/dind-node-rethinkdb-build-runner:$IMAGE_TAG
