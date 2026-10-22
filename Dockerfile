FROM docker.io/library/ubuntu:26.04
RUN apt-get update && \
    apt-get install -y --no-install-recommends bind9 bind9utils && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/bind/rndc.key && \
    rm -f /usr/bin/pebble && \
    chmod 640 /etc/bind/named.conf /etc/bind/named.conf.root-hints && \
    mkdir -p /run/named && chown bind:bind /run/named
COPY --chown=root:bind --chmod=640 named.conf.options /etc/bind/
COPY --chown=root:bind --chmod=640 named.conf.local /etc/bind/
EXPOSE 53/tcp 53/udp
CMD ["/usr/sbin/named", "-g", "-u", "bind", "-c", "/etc/bind/named.conf"]
