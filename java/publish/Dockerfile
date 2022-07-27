FROM maven:3.5-jdk-10 as maven

RUN apt-get update && apt-get install -y jq

RUN mkdir -p /usr/src/
WORKDIR /usr/src/

ENTRYPOINT [ "/bin/bash"]