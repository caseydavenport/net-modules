FROM djosborne/mesos-dockerized:0.26.0
MAINTAINER Dan Osborne <dan@projectcalico.org>

####################
# Isolator
####################
WORKDIR /isolator
ADD ./isolator/ /isolator/

# Build the isolator.
# We need libmesos which is located in /usr/local/lib.
RUN ./bootstrap && \
    mkdir build && \
    cd build && \
    export LD_LIBRARY_PATH=LD_LIBRARY_PATH:/usr/local/lib && \
    ../configure --with-mesos=/usr/local --with-protobuf=/usr && \
    make all

######################
# Calico
######################
COPY ./calico/ /calico/
ADD https://github.com/projectcalico/calico-docker/releases/download/v0.16.1/calicoctl /usr/local/bin/calicoctl 
RUN chmod +x /usr/local/bin/calicoctl

ADD https://github.com/projectcalico/calico-mesos/releases/download/v0.1.5/calico_mesos /calico/calico_mesos
RUN chmod +x /calico/calico_mesos

ENV LD_LIBRARY_PATH /usr/local/lib
