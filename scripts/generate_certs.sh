#!/bin/bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="${CERT_DIR:-${SCRIPT_DIR}/../nginx/certs}"
mkdir -p "$CERT_DIR"

# 1. Generate Root CA
echo "Generating Root CA..."
openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 \
    -keyout $CERT_DIR/rootCA.key -out $CERT_DIR/rootCA.pem -subj "/C=US/ST=State/L=City/O=Primus/CN=Primus Local CA"

# 2. Generate Nginx Certificate (localhost)
echo "Generating Nginx Certificate..."
openssl req -new -nodes -newkey rsa:2048 \
    -keyout $CERT_DIR/nginx.key -out $CERT_DIR/nginx.csr -subj "/C=US/ST=State/L=City/O=Primus/CN=localhost"

# Create extension file for SAN (Subject Alternative Name)
cat > $CERT_DIR/nginx.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = nginx
DNS.3 = backend
IP.1 = 127.0.0.1
EOF

# Sign Nginx Cert
openssl x509 -req -in $CERT_DIR/nginx.csr -CA $CERT_DIR/rootCA.pem -CAkey $CERT_DIR/rootCA.key -CAcreateserial \
    -out $CERT_DIR/nginx.crt -days 500 -sha256 -extfile $CERT_DIR/nginx.ext

# 3. Generate Mosquitto/Redis Certificate (internal/broker)
echo "Generating Service Certificate..."
openssl req -new -nodes -newkey rsa:2048 \
    -keyout $CERT_DIR/service.key -out $CERT_DIR/service.csr -subj "/C=US/ST=State/L=City/O=Primus/CN=mosquitto"

cat > $CERT_DIR/service.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = mosquitto
DNS.2 = redis
DNS.3 = postgres
DNS.4 = localhost
EOF

openssl x509 -req -in $CERT_DIR/service.csr -CA $CERT_DIR/rootCA.pem -CAkey $CERT_DIR/rootCA.key -CAcreateserial \
    -out $CERT_DIR/service.crt -days 500 -sha256 -extfile $CERT_DIR/service.ext

# Cleanup
rm $CERT_DIR/*.csr $CERT_DIR/*.ext

echo "Certificates generated in $CERT_DIR"
