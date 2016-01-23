FROM armv7/armhf-ubuntu_core:14.04

MAINTAINER Franco Fiorese <franco.fiorese@gmail.com>

# original Dockerfile from David Personette <dperson@dperson.com>
# just rebuilt for ARM hard float architecture

LABEL CMDBUILD="docker build -t f2hex/armhf-samba Dockerfile"
LABEL CMDRUN="sudo docker run --name samba -p 139:139 -p 445:445 -v /path/to/directory:/mount -d f2hex/armhf-samba"

# Install samba
RUN export DEBIAN_FRONTEND='noninteractive' && \
    apt-get update -qq && \
    apt-get upgrade -qqy && \
    apt-get install -qqy --no-install-recommends samba \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    useradd smbuser -M && \
    sed -i 's|^\(   log file = \).*|\1/dev/stdout|' /etc/samba/smb.conf && \
    sed -i 's|^\(   unix password sync = \).*|\1no|' /etc/samba/smb.conf && \
    sed -i '/Share Definitions/,$d' /etc/samba/smb.conf && \
    echo '   security = user' >>/etc/samba/smb.conf && \
    echo '   directory mask = 0775' >>/etc/samba/smb.conf && \
    echo '   force create mode = 0664' >>/etc/samba/smb.conf && \
    echo '   force directory mode = 0775' >>/etc/samba/smb.conf && \
    echo '   force user = smbuser' >>/etc/samba/smb.conf && \
    echo '   force group = users' >>/etc/samba/smb.conf && \
    echo '' >>/etc/samba/smb.conf
COPY samba.sh /usr/bin/

VOLUME ["/run", "/tmp", "/var/cache", "/var/lib", "/var/log", "/var/tmp", \
            "/etc/samba"]

EXPOSE 139 445

ENTRYPOINT ["samba.sh"]
