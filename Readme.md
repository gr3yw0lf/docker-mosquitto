# docker-mosquitto

Alpine based container for the mosquitto mqtt pub/sub server

Volume exposed: /var/lib/mosquitto /etc/mosquitto
(allows a data volume to be built with config, or mapped host dir)

### To Build

$ make

### To Make data volume

$ make build-data

### To run

$ make run-name

### Certificates

$ USE_SAN=SAN2 make all-certs
$ NAME=mqtt-server1 make copy-certs

