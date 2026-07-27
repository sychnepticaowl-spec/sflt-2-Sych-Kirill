#!/bin/bash
# Установка HAProxy без sudo (если нет прав root)
set -e
mkdir -p bin
cd /tmp
apt download haproxy
dpkg-deb -x haproxy_*.deb /tmp/haproxy_extract
cp /tmp/haproxy_extract/usr/sbin/haproxy bin/
echo "HAProxy installed to bin/haproxy"
bin/haproxy -v
