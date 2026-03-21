#!/@/bin/bash@
# Generate VPN client certificate and .mobileconfig for macOS
# Usage: generate-strongswan-client.sh <client-name>

set -euo pipefail

CLIENT_NAME="${1:-}"

if [[ -z "$CLIENT_NAME" ]]; then
    echo "Usage: $0 <client-name>"
    echo "Example: $0 dani"
    exit 1
fi

# Paths to encrypted CA certificate and key (replaced by NixOS)
CA_CERT="@ca_cert@"
CA_KEY="@ca_key@"

# Client working directory (relative to current working directory)
CLIENT_DIR="./vpn-$CLIENT_NAME"
LOG_FILE="$CLIENT_DIR/logs.log"

CLIENT_VALIDITY=3650  # 10 years

echo "=== Generating client certificate for: $CLIENT_NAME ==="

# Create client directory
mkdir -p "$CLIENT_DIR"
chmod 700 "$CLIENT_DIR"

# Initialize log file
cat > "$LOG_FILE" <<LOGEOF
=== Client Certificate Generation Log ===
Client Name: $CLIENT_NAME
Started: $(date)
CA_CERT: $CA_CERT
CA_KEY: $CA_KEY
CLIENT_DIR: $CLIENT_DIR
===

LOGEOF

echo "CA_CERT path: $CA_CERT" | tee -a "$LOG_FILE"
echo "CA_KEY path: $CA_KEY" | tee -a "$LOG_FILE"

# Check if CA files exist
if [[ -f "$CA_CERT" ]]; then
    echo "✓ CA_CERT file exists" | tee -a "$LOG_FILE"
else
    echo "✗ CA_CERT file NOT found at $CA_CERT" | tee -a "$LOG_FILE"
fi

if [[ -f "$CA_KEY" ]]; then
    echo "✓ CA_KEY file exists" | tee -a "$LOG_FILE"
else
    echo "✗ CA_KEY file NOT found at $CA_KEY" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# Generate client private key
echo "Generating client private key..." | tee -a "$LOG_FILE"
@openssl@ genrsa -out "$CLIENT_DIR/client-key.pem" 4096 2>&1 | tee -a "$LOG_FILE"
chmod 600 "$CLIENT_DIR/client-key.pem"
echo "✓ Private key generated" | tee -a "$LOG_FILE"

# Generate client CSR
echo "Generating client CSR..." | tee -a "$LOG_FILE"
@openssl@ req -new -key "$CLIENT_DIR/client-key.pem" \
    -out "$CLIENT_DIR/client-csr.pem" \
    -subj "/C=ES/O=Home/CN=$CLIENT_NAME@vpn.danielramos.me" 2>&1 | tee -a "$LOG_FILE"
echo "✓ CSR generated" | tee -a "$LOG_FILE"

# Create extensions file for client auth with SAN
echo "Creating extensions file..." | tee -a "$LOG_FILE"
cat > "$CLIENT_DIR/client-ext.cnf" <<EOF
authorityKeyIdentifier = keyid
subjectAltName = email:$CLIENT_NAME@vpn.danielramos.me
extendedKeyUsage = clientAuth,1.3.6.1.5.5.8.2.2
EOF
echo "✓ Extensions file created" | tee -a "$LOG_FILE"

# Sign client certificate with CA
echo "Signing client certificate with CA..." | tee -a "$LOG_FILE"
@openssl@ x509 -req -in "$CLIENT_DIR/client-csr.pem" \
    -CA "$CA_CERT" -CAkey "$CA_KEY" \
    -CAcreateserial -out "$CLIENT_DIR/client-cert.pem" \
    -days $CLIENT_VALIDITY -sha384 \
    -extfile "$CLIENT_DIR/client-ext.cnf" 2>&1 | tee -a "$LOG_FILE"
echo "✓ Client certificate signed" | tee -a "$LOG_FILE"

rm "$CLIENT_DIR/client-csr.pem" "$CLIENT_DIR/client-ext.cnf"

echo "✓ Client certificate created" | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "Generating PKCS#12 bundle..." | tee -a "$LOG_FILE"

# Generate PKCS#12 bundle for macOS (includes client cert + key + CA cert)
# Password: dani123
echo "Command: @openssl@ pkcs12 -export -inkey \"$CLIENT_DIR/client-key.pem\" -in \"$CLIENT_DIR/client-cert.pem\" -certfile \"$CA_CERT\" -out \"$CLIENT_DIR/$CLIENT_NAME.p12\" -name \"$CLIENT_NAME\" -passout pass:dani123" | tee -a "$LOG_FILE"
@openssl@ pkcs12 -export \
    -inkey "$CLIENT_DIR/client-key.pem" \
    -in "$CLIENT_DIR/client-cert.pem" \
    -certfile "$CA_CERT" \
    -out "$CLIENT_DIR/$CLIENT_NAME.p12" \
    -name "$CLIENT_NAME" \
    -passout pass:dani123 2>&1 | tee -a "$LOG_FILE"

if [[ $? -eq 0 ]]; then
    echo "✓ PKCS#12 bundle created successfully" | tee -a "$LOG_FILE"
else
    echo "✗ ERROR creating PKCS#12 bundle" | tee -a "$LOG_FILE"
fi

chmod 600 "$CLIENT_DIR/$CLIENT_NAME.p12"

echo "✓ PKCS#12 bundle created" | tee -a "$LOG_FILE"

# Make directory and files accessible to the user who invoked sudo
if [ -n "$SUDO_USER" ]; then
    chown -R "$SUDO_USER:users" "$CLIENT_DIR"
    chmod 755 "$CLIENT_DIR"
fi

echo "" | tee -a "$LOG_FILE"
echo "=== Generated Files ===" | tee -a "$LOG_FILE"
ls -lah "$CLIENT_DIR"/ | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "=== Client Configuration Complete ===" | tee -a "$LOG_FILE"
echo "Files generated in: $(pwd)/$CLIENT_DIR" | tee -a "$LOG_FILE"
echo "Full logs available in: $(pwd)/$LOG_FILE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Certificate and key:" | tee -a "$LOG_FILE"
echo "  - $CLIENT_DIR/client-cert.pem" | tee -a "$LOG_FILE"
echo "  - $CLIENT_DIR/client-key.pem" | tee -a "$LOG_FILE"
echo "  - $CLIENT_DIR/$CLIENT_NAME.p12" | tee -a "$LOG_FILE"
echo "  - $CLIENT_DIR/logs.log (this file)" | tee -a "$LOG_FILE"
