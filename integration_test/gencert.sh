#!/bin/bash
set -e

# Create a directory for the certificates if it doesn't exist
mkdir -p certs
cd certs

# 1. Generate Server CA
echo "Generating Server CA..."
openssl genpkey -algorithm ec -pkeyopt ec_paramgen_curve:P-256 -out server_ca.key
openssl req -x509 -new -nodes -key server_ca.key -sha256 -days 3650 -out server_ca.crt \
  -subj "/C=XX/ST=State/L=City/O=Hysteria/CN=Hysteria Server CA"

# 2. Generate Server Certificate
echo "Generating Server Certificate..."
openssl genpkey -algorithm ec -pkeyopt ec_paramgen_curve:P-256 -out server.key
openssl req -new -key server.key -out server.csr \
  -subj "/C=XX/ST=State/L=City/O=Hysteria/CN=example.com"

# Create server cert extensions config
cat > server.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = example.com
DNS.2 = *.example.com
IP.1 = 127.0.0.1
EOF

# Sign the server certificate with the Server CA
openssl x509 -req -in server.csr -CA server_ca.crt -CAkey server_ca.key -CAcreateserial \
  -out server.crt -days 365 -sha256 -extfile server.ext

# 3. Generate Client CA
echo "Generating Client CA..."
openssl genpkey -algorithm ec -pkeyopt ec_paramgen_curve:P-256 -out client_ca.key
openssl req -x509 -new -nodes -key client_ca.key -sha256 -days 3650 -out client_ca.crt \
  -subj "/C=XX/ST=State/L=City/O=Hysteria/CN=Hysteria Client CA"

# 4. Generate Client Certificate
echo "Generating Client Certificate..."
openssl genpkey -algorithm ec -pkeyopt ec_paramgen_curve:P-256 -out client.key
openssl req -new -key client.key -out client.csr \
  -subj "/C=XX/ST=State/L=City/O=Hysteria/CN=Hysteria Client"

# Create client cert extensions config
cat > client.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = clientAuth
EOF

# Sign the client certificate with the Client CA
openssl x509 -req -in client.csr -CA client_ca.crt -CAkey client_ca.key -CAcreateserial \
  -out client.crt -days 365 -sha256 -extfile client.ext

# Clean up temporary files
echo "Cleaning up..."
rm *.csr *.ext *.srl

echo "Certificates generated successfully in the 'certs' directory."
cd ..
