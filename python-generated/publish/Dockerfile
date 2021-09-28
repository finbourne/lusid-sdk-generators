FROM python:3.7.0

RUN pip install cryptography==3.3.1 twine

RUN mkdir -p /usr/src/
RUN mkdir -p /usr/work/

WORKDIR /usr/src/

ENTRYPOINT [ "/bin/bash"]