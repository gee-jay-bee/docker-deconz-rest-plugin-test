ARG PLUGIN_REPOSITORY=https://github.com/dresden-elektronik/deconz-rest-plugin.git
ARG PLUGIN_GIT_COMMIT=master

FROM debian:10-slim as compile-plugin
#FROM arm64v8/debian:10.9-slim as compile-plugin

ENV DEBIAN_FRONTEND="noninteractive"
ENV TERM="xterm"

RUN apt-get update && apt-get install -y git qt5-default libqt5websockets5-dev libqt5serialport5-dev sqlite3 libcap2-bin lsof curl libsqlite3-dev libssl-dev g++ make gnupg2

RUN curl -L http://phoscon.de/apt/deconz.pub.key | apt-key add -
#RUN sh -c "echo 'deb http://phoscon.de/apt/deconz $(cat /etc/os-release | grep -oP '(?<=VERSION_CODENAME\=).*') main' > /etc/apt/sources.list.d/deconz.list"
RUN sh -c "echo 'deb http://phoscon.de/apt/deconz $(cat /etc/os-release | grep -oP '(?<=VERSION_CODENAME\=).*')-beta main' > /etc/apt/sources.list.d/deconz.list"

RUN apt-get update && apt-get install -y deconz deconz-dev
#RUN cat /etc/apt/sources.list.d/deconz.list

#ADD http://deconz.dresden-elektronik.de/debian/beta/deconz_2.11.05-debian-stretch-beta_arm64.deb /deconz.deb
#RUN dpkg -i /deconz.deb && rm -f /deconz.deb

#ADD http://deconz.dresden-elektronik.de/debian/beta/deconz-dev_2.11.05-debian-stretch-beta_arm64.deb /deconz-dev.deb
#RUN dpkg -i /deconz-dev.deb && rm -f /deconz-dev.deb

# Get code from repository and compile 

ARG PLUGIN_REPOSITORY
ARG PLUGIN_GIT_COMMIT

#RUN echo ${PLUGIN_REPOSITORY}
RUN git clone ${PLUGIN_REPOSITORY} && cd deconz-rest-plugin && git checkout ${PLUGIN_GIT_COMMIT} && qmake && make -j2

FROM marthoc/deconz:latest AS final-image
#FROM marthoc/deconz:stable AS final-image

COPY --from=compile-plugin /libde_rest_plugin.so /usr/share/deCONZ/plugins/libde_rest_plugin.so
