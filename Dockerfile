FROM debian:latest
USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg \
		iproute2 \
		openjdk-11-jre-headless \
		procps \
		systemd \
		vim \
		wget && \
	echo "deb http://repo.mongodb.org/apt/debian bullseye/mongodb-org/5.0 main" > /etc/apt/sources.list.d/mongodb-org-5.0.list && \
	wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/mongodb-org-5.0.gpg >/dev/null && \
	echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' > /etc/apt/sources.list.d/100-ubnt-unifi.list && \
	wget -qO /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg && \
	apt update && \
	apt install -y --no-install-recommends mongodb-org && \
	systemctl enable mongod && \
	apt-get download unifi && \
	dpkg-deb -R /unifi*.deb /tmp/deb && \
	grep -v mongodb /tmp/deb/DEBIAN/control > /tmp/deb/DEBIAN/control-tmp && \
	mv -f /tmp/deb/DEBIAN/control-tmp /tmp/deb/DEBIAN/control && \
	dpkg-deb -b /tmp/deb /unifi-fixed-deps.deb && \
	apt-get install -y --no-install-recommends /unifi-fixed-deps.deb && \
	mkdir -p /etc/systemd/system/unifi.service.d && \
	echo "[Service]\nUser=root" >> /etc/systemd/system/unifi.service.d/override.conf && \
	rm -f /*.deb && \
	systemctl enable unifi && \
	apt-get clean && \
	rm -Rf /var/lib/apt/lists/*

CMD ["/lib/systemd/systemd"]
