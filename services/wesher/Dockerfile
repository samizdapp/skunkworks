FROM balenalib/aarch64-debian

WORKDIR /
RUN install_packages wget miniupnpc dnsutils inotify-tools
RUN wget -O wesher https://github.com/costela/wesher/releases/latest/download/wesher-arm64
RUN chmod a+x wesher
COPY run.sh run.sh
COPY hosts_updated.sh .
COPY watch_hosts.sh .
RUN chmod a+x wesher run.sh hosts_updated.sh watch_hosts.sh
CMD [ "/run.sh" ]