#!/bin/sh

apt update
apt install -y \
  ca-certificates \
  gcc \
  git \
  libc6-dev \
  liblua5.3-dev \
  libpcre3-dev \
  libssl-dev \
  libsystemd-dev \
  make \
  zlib1g-dev

cd ~
git clone https://github.com/quictls/openssl
cd openssl
git checkout openssl-3.1.4-quic1
 mkdir -p /opt/quictls

./Configure --libdir=lib --prefix=/opt/quictls
make
make install
cd ~
rm -rf ~/openssl 

cd ~
git clone https://github.com/haproxy/haproxy.git
cd haproxy
git checkout v2.8.0

make TARGET=linux-glibc \
    USE_LUA=1 \
    USE_PCRE=1 \
    USE_ZLIB=1 \
    USE_SYSTEMD=1 \
    USE_PROMEX=1 \
    USE_QUIC=1 \
    USE_OPENSSL=1 \
    SSL_INC=/opt/quictls/include \
    SSL_LIB=/opt/quictls/lib \
    LDFLAGS="-Wl,-rpath,/opt/quictls/lib"

make install-bin
cd admin/systemd
make haproxy.service
cp ./haproxy.service /etc/systemd/system/

mkdir -p /etc/haproxy
mkdir -p /run/haproxy
touch /etc/haproxy/haproxy.cfg

systemctl enable haproxy
systemctl start haproxy

# housekeeping
cd ~
rm -rf openssl
rm -rf haproxy

echo 'done'