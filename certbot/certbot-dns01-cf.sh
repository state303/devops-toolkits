#!/bin/sh

# host may be multiple, comma separated sequence.

echo 'checking requirements...'
if [ -z "$CF_API_TOKEN" ] ; then echo "Missing \$API_TOKEN variable set" ; exit 1 ; fi
if [ -z "$HOST" ] ; then echo "Missing \$HOST variable set" ; exit 1 ; fi
if [ "$(id -u)" -ne 0 ] ; then echo "Please run as root" ; exit 1 ; fi
echo 'done'

echo 'install certbot...'
sudo snap install core && sudo snap refresh core && sudo snap install --classic certbot
echo 'done'

echo 'setup certbot...'
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo snap set certbot trust-plugin-with-root=ok
sudo snap install certbot-dns-cloudflare
echo 'done'

echo 'preparing cloudflare.ini...'
sudo mkdir -p /etc/secrets/certbot

echo "dns_cloudflare_api_token=$API_TOKEN" > /etc/secrets/certbot/cloudflare.ini
echo 'done'

echo "issuing certificate(s)..."
sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/secrets/certbot/cloudflare.ini \
  -d "$HOST"
echo 'done'
