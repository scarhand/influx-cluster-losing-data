FROM debian:jessie

MAINTAINER Niels van der Zanden "niels@phusion.nl"

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates apt-transport-https && \
    curl -sL https://repos.influxdata.com/influxdb.key | apt-key add - && \
    echo "deb https://repos.influxdata.com/debian jessie stable" | tee /etc/apt/sources.list.d/influxdb.list && \
    apt-get update && \
    apt-get install -y influxdb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

ENV WAIT "true"

COPY influxdb.conf /etc/influxdb/influxdb.conf
COPY init.sh /init.sh
COPY add_node_to_hosts.sh /add_node_to_hosts.sh

ENTRYPOINT ["/init.sh"]