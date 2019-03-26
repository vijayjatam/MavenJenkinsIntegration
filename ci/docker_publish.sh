#!/bin/bash

# This script is intended to be run by Jenkins CI, not locally.
#
# Builds Docker image and adds Git tag. This is only performed if the
# branch being committed to is release, master, or epic-*, or if
# the build was requested via the Travis API (e.g. via
# docker_publish.sh)

set -e

echo Logging into Docker Hub as ${DOCKER_USER}...
echo "${DOCKER_PASS:?}" | docker login -u "${DOCKER_USER:?}" --password-stdin

# We always want to build the Docker image, even when we decide it should not be pushed
echo Building Docker image ${DOCKER_IMAGE}...
docker build --file ./ci/Dockerfile --tag "${DOCKER_IMAGE}:test" .

echo TRAVIS_BRANCH=$TRAVIS_BRANCH
echo TRAVIS_PULL_REQUEST=$TRAVIS_PULL_REQUEST
echo TRAVIS_EVENT_TYPE=$TRAVIS_EVENT_TYPE

### Conditionally build & publish Docker images to follow our team's development workflow

if [[ $TRAVIS_EVENT_TYPE == "api" ]]; then
    echo "Performing Docker image publishing for ad hoc build request for branch ${TRAVIS_BRANCH}"
    DOCKER_TAG="${TRAVIS_BRANCH}-b${TRAVIS_BUILD_NUMBER}-${TRAVIS_COMMIT}"
    GIT_TAG=""
elif [[ $TRAVIS_BRANCH == "release" && $TRAVIS_PULL_REQUEST == "false" ]]; then
    # If `release` branch commit, we consider it a Release ("release") that is
    # ready to be deployed to production environment
    DOCKER_TAG="release${TRAVIS_BUILD_NUMBER}"
    GIT_TAG=$DOCKER_TAG
    GIT_MESSAGE="Production Release"
elif [[ $TRAVIS_BRANCH == "master" && $TRAVIS_PULL_REQUEST == "false" ]]; then
    # If master branch commit, we consider it a Release Candidate ("rc") that is
    # ready to be tested in a staging environment
    DOCKER_TAG="rc${TRAVIS_BUILD_NUMBER}"
    GIT_TAG=$DOCKER_TAG
    GIT_MESSAGE="Release Candidate"
elif [[ $TRAVIS_BRANCH =~ ^epic- && $TRAVIS_PULL_REQUEST == "false" ]]; then
    DOCKER_TAG="${TRAVIS_BRANCH}-b${TRAVIS_BUILD_NUMBER}"
    GIT_TAG=$DOCKER_TAG
    GIT_MESSAGE="Test build for '${TRAVIS_BRANCH}'"
else
   echo "Skipping Docker image publishing for non-release/master/epic branch ${TRAVIS_BRANCH}, pull request ${TRAVIS_PULL_REQUEST}"
   exit 0
fi

echo Publishing Docker image ${DOCKER_IMAGE}
docker tag "${DOCKER_IMAGE}:test" "${DOCKER_IMAGE}:${DOCKER_TAG}"

echo Pushing Docker image ${DOCKER_IMAGE}...
docker push "${DOCKER_IMAGE}:${DOCKER_TAG}"

### Tag git repo for Release Candidate version and Production Release versions

if [[ $GIT_TAG ]]; then
    echo Adding Git tag $GIT_TAG
    git tag -a -m "$GIT_MESSAGE" ${GIT_TAG} ${TRAVIS_COMMIT}
    git push --tags origin
fi

echo Done Publishing Docker image ${DOCKER_IMAGE}