FROM openjdk:8u131-jre-alpine
LABEL maintainer="vijay.jatam.consultant@nielsen.com"

ENV HW_HOME=/opt/
WORKDIR $HW_HOME

# jar file argument
ARG jar_file

# Define jar_file as env var, for use by docker_entrypoint.sh when Docker image is run
ENV JAR_FILE $jar_file

COPY ${jar_file} ci/docker_entrypoint.sh $HW_HOME

CMD ["chmod", "+x", "/opt/docker_entrypoint.sh"]

ENTRYPOINT /opt/docker_entrypoint.sh

# ADD HelloWorld.class $HW_HOME/

# ENTRYPOINT ["java", "HelloWorld"]