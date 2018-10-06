#!/bin/bash -e

ARTIFACTS="_ARTIFACTS"
DOCKER_REGISTRY="nonexistant.vortex-rpm.org"

if [ ! -d $ARTIFACTS ] ; then
	mkdir -p $ARTIFACTS
fi

while read line
do
	PECL_NAME=$(echo ${line} | awk '{print $1}')
	NAME=$(echo ${line} | awk '{print $2}')
	VERSION=$(echo ${line} | awk '{print $3}')
	ITERATION=$(echo ${line} | awk '{print $4}')
	DEPS=$(echo ${line} | awk '{print $5}')
	URL=$(echo ${line} | awk '{print $6}')

	tag="${DOCKER_REGISTRY}/build-${NAME}:latest"
	echo "Building ${tag}"
	docker build --pull -t ${tag} --build-arg PECL_NAME=${PECL_NAME} --build-arg NAME=${NAME} --build-arg VERSION=${VERSION} --build-arg ITERATION=${ITERATION} --build-arg DEPS=${DEPS} --build-arg URL=${URL} .

	docker cp $(docker create ${tag}):/BUILDROOT/${NAME}-${VERSION}-${ITERATION}.x86_64.rpm ${ARTIFACTS}/
done < packages.txt
