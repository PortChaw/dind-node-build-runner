#!/bin/bash

docker build -t portchaw/dind-node-rethink-build-runner . && \
  NODE_VER=$(docker run --rm --privileged portchaw/dind-node-rethink-build-runner node --version) && \
  IMAGE_TAG=${NODE_VER#"v"} && \
  docker tag portchaw/dind-node-rethink-build-runner portchaw/dind-node-rethink-build-runner:$IMAGE_TAG && \
  docker push portchaw/dind-node-rethink-build-runner
