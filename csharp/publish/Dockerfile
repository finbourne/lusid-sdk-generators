FROM mcr.microsoft.com/dotnet/core/sdk:3.1

RUN apt-get update && apt-get install -y jq

RUN mkdir -p /usr/src/
RUN mkdir -p /usr/work/
WORKDIR /usr/src/

ENTRYPOINT [ "/bin/bash"]