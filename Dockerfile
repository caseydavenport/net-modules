FROM mesosphere/mesos-modules-dev-phusion:0.27.1
MAINTAINER Dan Osborne <dan@projectcalico.org>

####################
# Mesos-DNS
####################
RUN curl -LO https://github.com/mesosphere/mesos-dns/releases/download/v0.5.0/mesos-dns-v0.5.0-linux-amd64 && \
    mv mesos-dns-v0.5.0-linux-amd64 /usr/bin/mesos-dns && \
    chmod +x /usr/bin/mesos-dns

###################
# Docker
###################
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Define additional metadata for our image.
VOLUME /var/lib/docker

#######################
# Star (test workload)
#######################
WORKDIR /star

ADD http://downloads.mesosphere.io/demo/star/v0.5.0/star-collect-v0.5.0-linux-x86_64 /star/
RUN chmod +x star-collect-v0.5.0-linux-x86_64
ADD http://downloads.mesosphere.io/demo/star/v0.5.0/star-probe-v0.5.0-linux-x86_64 /star/
RUN chmod +x star-probe-v0.5.0-linux-x86_64

COPY ./demo/marathon/star-resources-before.json /star/star-resources-before.json
COPY ./demo/marathon/star-resources.json /star/star-resources.json
COPY ./demo/marathon/star-iso-resources.json /star/star-iso-resources.json

#################
# Init scripts
#################
ADD ./init_scripts/etc/service/mesos_slave/run /etc/service/mesos_slave/run
ADD ./init_scripts/etc/service/docker/run /etc/service/docker/run
ADD ./init_scripts/etc/service/calico/run /etc/service/calico/run
ADD ./init_scripts/etc/service/mesos-dns/run /etc/service/mesos-dns/run
ADD ./init_scripts/etc/config/mesos-dns.json /etc/config/mesos-dns.json


######################
# Calico
######################
COPY ./calico/ /calico/
ADD https://github.com/projectcalico/calico-docker/releases/download/v0.19.0/calicoctl /usr/local/bin/calicoctl 
RUN chmod +x /usr/local/bin/calicoctl
ADD https://github.com/projectcalico/calico-mesos/releases/download/v0.1.6/calico_mesos /calico/calico_mesos
RUN chmod +x /calico/calico_mesos
