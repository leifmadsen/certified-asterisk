# Version: 0.0.1
FROM centos:7
MAINTAINER AVOXI DevOps "devops@avoxi.com"
ENV REFRESHED_AT 2015-09-01
ENV DOWNLOAD_URL http://downloads.asterisk.org/pub/telephony/certified-asterisk
ENV ASTVERSION certified-asterisk-13.1-cert2
ENV TARGET_DIR /usr/src/
ENV DEV_PKG_LIST automake \
    gcc \
    gcc-c++ \
    ncurses-devel \
    openssl-devel \
    libxml2-devel \
    unixODBC-devel \
    libcurl-devel \
    libogg-devel \
    libvorbis-devel \
    speex-devel \
    net-snmp-devel \
    corosynclib-devel \
    newt-devel \
    popt-devel \
    libtool-ltdl-devel \
    sqlite-devel \
    neon-devel \
    jansson-devel \
    libsrtp-devel \
    pjproject-devel \
    libxslt-devel \
    libuuid-devel \
    gsm-devel \
    gmime-devel \
    iksemel-devel

ENV RUN_PKG_LIST pjproject jansson neon unixODBC vorbis gmime iksemel

# install dependencies
RUN yum -q makecache && yum install tar epel-release -y && yum install -q -y $DEV_PKG_LIST $RUN_PKG_LIST

# obtain and extract the source
WORKDIR $TARGET_DIR
ADD $DOWNLOAD_URL/$ASTVERSION.tar.gz $TARGET_DIR
RUN tar zxvf $ASTVERSION.tar.gz

# build Asterisk
WORKDIR $TARGET_DIR/$ASTVERSION
RUN ./configure
WORKDIR $TARGET_DIR/$ASTVERSION/menuselect
RUN make menuselect
WORKDIR $TARGET_DIR/$ASTVERSION
RUN make menuselect-tree

RUN menuselect/menuselect \
    --disable-category MENUSELECT_ADDONS \
    --disable-category MENUSELECT_CORE_SOUNDS \
    --disable-category MENUSELECT_MOH \
    --disable-category MENUSELECT_EXTRA_SOUNDS \
    --disable-category MENUSELECT_AGIS \
    --disable-category MENUSELECT_TESTS \
    --enable res_hep \
    --enable res_hep_pjsip \
    --enable res_hep_rtcp \
    --enable res_statsd \
    --enable chan_sip

RUN make
RUN make install

# clean up
WORKDIR $TARGET_DIR
RUN rm -rf $ASTVERSION
RUN yum remove -y -q tar $DEV_PKG_LIST && yum autoremove -y && yum clean all && rm -f $TARGET_DIR/$ASTVERSION.tar.gz

# start the system
WORKDIR /usr/sbin
ENTRYPOINT [ "asterisk" ]
CMD [ "-c", "-g" ]
