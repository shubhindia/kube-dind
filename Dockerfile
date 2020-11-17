FROM docker:18.09.7


# Install essentials 
RUN apk add curl vim jq
# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN set -eux; \
	apk add --no-cache \
		btrfs-progs \
		e2fsprogs \
		e2fsprogs-extra \
		iptables \
		openssl \
		shadow-uidmap \
		xfsprogs \
		xz \
# pigz: https://github.com/moby/moby/pull/35697 (faster gzip implementation)
		pigz \
	; \
# only install zfs if it's available for the current architecture
# https://git.alpinelinux.org/cgit/aports/tree/main/zfs/APKBUILD?h=3.6-stable#n9 ("all !armhf !ppc64le" as of 2017-11-01)
# "apk info XYZ" exits with a zero exit code but no output when the package exists but not for this arch
	if zfs="$(apk info --no-cache --quiet zfs)" && [ -n "$zfs" ]; then \
		apk add --no-cache zfs; \
	fi

# OpenVPN client
ENV GPG_THUMBPRINT ${GPG_THUMBPRINT:-0xbe07d9fd54809ab2c4b0ff5f63762cda67e2f359}

# openconnect deps and gnu build system
RUN apk add --no-cache tar coreutils gnupg gcc make autoconf automake \
        libtool libxml2-dev linux-headers make musl-dev openssl-dev

# download, gpg verify openconnect, build pre-prep
RUN wget ftp://ftp.infradead.org/pub/openconnect/openconnect-8.10.tar.gz && \
    #wget ftp://ftp.infradead.org/pub/openconnect/openconnect-8.10.tar.gz.asc && \
    tar -xzpf openconnect-8.10.tar.gz

RUN wget ftp://ftp.infradead.org/pub/vpnc-scripts/vpnc-scripts-20200930.tar.gz && \
    tar -xzpf vpnc-scripts-20200930.tar.gz && \
    mkdir /etc/vpnc && \
    cp vpnc-scripts-20200930/vpnc-script /etc/vpnc/ 

#Build and install openconnect VPN client
RUN cd /openconnect-8.10/ && \
    ./configure --prefix $(pwd)/build/usr/local --disable-nls && \
    make -j 4 && \
    make install

#Helm
ENV HELM_VERSION="v3.4.0"
RUN apk add --no-cache ca-certificates bash git openssh curl \
    && wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -x \
	&& addgroup -S dockremap \
	&& adduser -S -G dockremap dockremap \
	&& echo 'dockremap:165536:65536' >> /etc/subuid \
	&& echo 'dockremap:165536:65536' >> /etc/subgid

ADD dind /usr/local/bin/
RUN set -eux; \
	chmod +x /usr/local/bin/dind

COPY dockerd-entrypoint.sh /
RUN chmod +x /dockerd-entrypoint.sh
VOLUME /var/lib/docker

## Kubernetes stuff
ADD kubectx /usr/local/bin/
ADD kubectl /usr/local/bin/
COPY get_kubeconfig.sh /
RUN chmod +x /get_kubeconfig.sh
EXPOSE 2375 2376
ENTRYPOINT ["./dockerd-entrypoint.sh"]
CMD []
