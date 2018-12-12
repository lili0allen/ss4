#/bin/bash

docker build . --target buildprod --build-arg SKIPTESTS=true -t ss4-build:latest

docker run --mount type=bind,source=$(pwd)/src/main,target=/var/www/website -it ss4-build:latest composer $*