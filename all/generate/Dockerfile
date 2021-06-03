FROM maven:3.6.3-jdk-11 as maven

RUN apt-get update && apt-get -y install jq && apt-get -y install git

RUN mkdir -p /usr/src/
WORKDIR /usr/src/

RUN wget https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/5.1.0/openapi-generator-cli-5.1.0.jar -O openapi-generator-cli.jar

ENTRYPOINT [ "/bin/bash" ]