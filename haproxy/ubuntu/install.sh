#!/bin/sh
sudo apt update
sudo apt install -y git ca-certificates gcc libc6-dev liblua5.3-dev libpcre3-dev libssl-dev libsystemd-dev make wget zlib1g-dev
git clone https://github.com/haproxy/haproxy.git
cd haproxy || exit
make TARGET=linux-glibc USE_LUA=1 USE_OPENSSL=1 USE_PCRE=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_PROMEX=1
sudo make install-bin
sudo systemctl start haproxy