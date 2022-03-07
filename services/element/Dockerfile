FROM balenalib/aarch64-debian

RUN install_packages tar

WORKDIR /app

RUN rm -rf element-v1.9.9
COPY element-v1.9.9.tar.gz .
RUN tar -xf element-v1.9.9.tar.gz
COPY config.json ./element-v1.9.9/


CMD ["balena-idle"]