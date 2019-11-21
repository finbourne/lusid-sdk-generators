FROM maven:3.5-jdk-10

RUN apt-get update && apt-get -y install jq && apt-get -y install git

RUN mkdir -p /usr/src/
WORKDIR /usr/src/

RUN wget http://central.maven.org/maven2/org/openapitools/openapi-generator-cli/4.2.1/openapi-generator-cli-4.2.1.jar -O openapi-generator-cli.jar

ENTRYPOINT [ "/bin/bash" ]