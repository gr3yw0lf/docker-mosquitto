FROM gliderlabs/alpine:3.4

MAINTAINER Grey Whittney <grey@gr3yw0lf.com>

RUN addgroup mosquitto && adduser -D -H -G mosquitto -S mosquitto

RUN apk-install --update mosquitto tini

ADD mosquitto.conf /etc/mosquitto/mosquitto.conf

RUN mkdir -p /etc/mosquitto/conf.d \
	&& touch /var/run/mosquitto.pid \
	&& mkdir -p /var/lib/mosquitto \
	&& chown -R mosquitto /etc/mosquitto /var/run/mosquitto.pid /var/lib/mosquitto

EXPOSE 1883 8883 9001 9444

VOLUME /var/lib/mosquitto/
VOLUME /etc/mosquitto/

USER mosquitto

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/sbin/mosquitto","-c","/etc/mosquitto/mosquitto.conf"]

