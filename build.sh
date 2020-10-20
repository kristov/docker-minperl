#!/bin/sh
docker build -t minperl-builder -f Dockerfile.builder .
docker run --rm minperl-builder tar cC build . | xz -T0 -z9 > minperl.tar.xz
docker build -t minperl .
