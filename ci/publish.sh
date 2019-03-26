#!/usr/bin/env bash

echo 'The following Maven command installs your Maven-built Java application'
echo 'into the local Maven repository, which will ultimately be stored in'
echo 'Jenkins''s local Maven repository (and the "maven-repository" Docker data'
echo 'volume).'
set -x
mvn jar:jar install:install help:evaluate -Dexpression=project.name
set +x

echo 'The following complex command extracts the value of the <name/> element'
echo 'within <project/> of your Java/Maven project''s "pom.xml" file.'
set -x
NAME=`mvn help:evaluate -Dexpression=project.name | grep "^[^\[]"`
set +x

echo 'The following complex command behaves similarly to the previous one but'
echo 'extracts the value of the <version/> element within <project/> instead.'
set -x
VERSION=`mvn help:evaluate -Dexpression=project.version | grep "^[^\[]"`
set +x

echo 'The following command runs and outputs the execution of your Java'
echo 'application (which Jenkins built using Maven) to the Jenkins UI.'
set -x
java -jar target/${NAME}-${VERSION}.jar

echo "BUILD_NUMBER" :: $BUILD_NUMBER
echo "BUILD_ID" :: $BUILD_ID
echo "BUILD_DISPLAY_NAME" :: $BUILD_DISPLAY_NAME
echo "JOB_NAME" :: $JOB_NAME
echo "JOB_BASE_NAME" :: $JOB_BASE_NAME
echo "BUILD_TAG" :: $BUILD_TAG
echo "EXECUTOR_NUMBER" :: $EXECUTOR_NUMBER
echo "NODE_NAME" :: $NODE_NAME
echo "NODE_LABELS" :: $NODE_LABELS
echo "WORKSPACE" :: $WORKSPACE
echo "JENKINS_HOME" :: $JENKINS_HOME
echo "JENKINS_URL" :: $JENKINS_URL
echo "BUILD_URL" ::$BUILD_URL
echo "JOB_URL" :: $JOB_URL

DOCKER_IMAGE="vijaykumar243/maven-jenkins-integration"
DOCKER_TAG="master-b${BUILD_NUMBER}"
echo "Logging into Docker Hub as ${DOCKER_USER}..."
docker login --username=vijaykumar243 --password=Secure*12 $DOCKER_HOST

docker info

# We always want to build the Docker image, even when we decide it should not be pushed
echo "Building Docker image ${DOCKER_IMAGE}..."
docker build --file ./ci/Dockerfile --build-arg jar_file=${NAME}-${VERSION}.jar --tag "${DOCKER_IMAGE}:${BUILD_NUMBER}" .

echo "Publishing Docker image ${DOCKER_IMAGE}"
docker tag "${DOCKER_IMAGE}:${BUILD_NUMBER}" "${DOCKER_IMAGE}:${DOCKER_TAG}"

# docker build -t katacoda/jenkins-demo:${BUILD_NUMBER} .
# docker tag katacoda/jenkins-demo:${BUILD_NUMBER} vijaykumar243/jenkins-demo:latest
# docker images
# docker push vijaykumar243/jenkins-demo:latest


echo Pushing Docker image ${DOCKER_IMAGE}...
docker push "${DOCKER_IMAGE}:${DOCKER_TAG}"
