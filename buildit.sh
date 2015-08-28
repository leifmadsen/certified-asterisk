#!/usr/bin/env bash

# RUN ["buildit.sh", "$DOWNLOAD_URL", "$ASTVERSION", "$TARGET_URL", "$PKG_LIST"]
DOWNLOAD_URL=$1
ASTVERSION=$2
TARGET_DIR="/usr/src"
PKG_LIST="automake gcc gcc-c++ ncurses-devel openssl-devel libxml2-devel unixODBC-devel libcurl-devel libogg-devel libvorbis-devel speex-devel net-snmp-devel corosynclib-devel newt-devel popt-devel libtool-ltdl-devel sqlite-devel libsq3-devel neon-devel jansson-devel libsrtp-devel pjproject-devel libxslt-devel libuuid-devel gsm-devel"

echo "Installing packages"
yum -q makecache && yum install wget tar findutils epel-release -y && yum install -q -y $PKG_LIST

# further reduce the size of the build by reducing the locale-archive
localedef --list-archive | grep -v -i ^en | xargs localedef --delete-from-archive && mv -f /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && build-locale-archive

cd $TARGET_DIR

echo "Getting source"
wget $DOWNLOAD_URL/$ASTVERSION.tar.gz

echo "Extracting source"
tar zxvf $ASTVERSION.tar.gz
cd $TARGET_DIR/$ASTVERSION

echo "Checking for dependencies"
./configure

echo "Building menuselect"
cd menuselect
make menuselect
cd ..
make menuselect-tree

echo "Setting up modules to build"
menuselect/menuselect \
    --disable-category MENUSELECT_ADDONS \
    --disable-category MENUSELECT_CORE_SOUNDS \
    --disable-category MENUSELECT_MOH \
    --disable-category MENUSELECT_EXTRA_SOUNDS \
    --disable-category MENUSELECT_AGIS \
    --disable-category MENUSELECT_TESTS

echo "Compiling..."
make

echo "Installing binaries"
make install
cd ..

echo "Cleaning up everything"
rm -rf $ASTVERSION*
yum remove -y -q $PKG_LIST wget tar findutils && yum autoremove -y && yum clean all
