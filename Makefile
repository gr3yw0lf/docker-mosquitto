DOCKERFILE_FOLDER=.
OWNER=gr3yw0lf
NAME=mqtt_mosquitto
VERSION=$(shell cat version)

TAG=${OWNER}/${NAME}:${VERSION}

RUNNAME=mqtt_server_1
DATANAME=mqtt_server_1_data

DEBUG_OPTS=-P -v `pwd`/data:/data
OPTS=-P --volumes-from=${DATANAME}

CA_SUBJ=/C=US/ST=XX/O=mqtt security/CN=ca.mqtt.local
SAN1=DNS:*.mydomain.info,DNS:*.mydomain2.local,DNS:localhost
SAN2=DNS:*.mydomain.info,DNS:*.mydomain2.local,DNS:localhost,IP:10.20.30.40
CERT_PREFIX_SUBJ=/C=US/ST=NC/O=mydomain.info mqtt security
CERT_POSTFIX_SUBJ=mydomain.info
#ifndef USE_SAN
	USE_SAN=SAN1
#endif

build: dir-data Dockerfile
	docker build -t ${TAG} ${DOCKERFILE_FOLDER}

run-debug: dir-data
	docker run --rm ${DEBUG_OPTS} -it ${TAG} /bin/ash

run-name: 
	docker run ${OPTS} --name=${RUNNAME} -d ${TAG} 

dir-data:
	mkdir -p data

build-data:
	docker create --name=${DATANAME} ${TAG}

copy-certs:
	for file in ca.crt ${NAME}.crt ${NAME}.key; do \
		docker cp $$file ${DATANAME}:/etc/mosquitto/ \
	done

.SECONDARY:

all-certs: ca.crt mqtt-server1.crt mqtt-server2.crt mqtt-client1.crt 

%.key :
	openssl genrsa -out $@ 2048

ca.crt: ca.key
	openssl req -subj "${CA_SUBJ}" -x509 -new -nodes -key $(basename $@).key -sha256 -days 3600 -out $@

openssl.cnf:
	cp /etc/ssl/$@ ./$@ && \
	printf "\n\n[SAN1]\nsubjectAltName=${SAN1}\n" >> ./$@ && \
	printf "\n\n[SAN2]\nsubjectAltName=${SAN2}\n" >> ./$@

%.csr: %.key openssl.cnf
	openssl req \
		-subj "${CERT_PREFIX_SUBJ}/CN=$(basename $@).${CERT_POSTFIX_SUBJ}" \
		-new \
		-reqexts ${USE_SAN} \
		-config ./openssl.cnf \
		-key $(basename $@).key \
		-out $@

%.crt: %.csr
	openssl x509 \
		-extensions ${USE_SAN} -extfile ./openssl.cnf \
		-req -in $< \
		-CA ca.crt -CAkey ca.key -CAcreateserial \
		-days 500 -sha256 \
		-out $@

