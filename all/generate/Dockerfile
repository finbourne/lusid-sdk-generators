FROM maven:3.5-jdk-10

RUN apt-get update && apt-get -y install jq && apt-get -y install git

RUN mkdir -p /usr/src/
WORKDIR /usr/src/

RUN wget https://oss.sonatype.org/content/repositories/snapshots/org/openapitools/openapi-generator-cli/4.3.0-SNAPSHOT/openapi-generator-cli-4.3.0-20200228.170235-150.jar -O openapi-generator-cli.jar

ENTRYPOINT [ "/bin/bash" ]