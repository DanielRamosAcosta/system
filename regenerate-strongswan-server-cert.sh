#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

AGENIX_DIR="/run/agenix"
TEMP_DIR="/tmp/strongswan-regen"
CERT_CN="vpn.danielramos.me"
CERT_VALIDITY_DAYS=3650  # 10 years, same as original

echo -e "${YELLOW}=== StrongSwan Server Certificate Regeneration ===${NC}"
echo "This script will regenerate the server certificate with SAN extension"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run as root${NC}"
  exit 1
fi

# Check if agenix files exist
if [ ! -f "$AGENIX_DIR/strongswan-ca-cert-pem" ]; then
  echo -e "${RED}Error: CA certificate not found at $AGENIX_DIR/strongswan-ca-cert-pem${NC}"
  exit 1
fi

if [ ! -f "$AGENIX_DIR/strongswan-ca-key-pem" ]; then
  echo -e "${RED}Error: CA key not found at $AGENIX_DIR/strongswan-ca-key-pem${NC}"
  exit 1
fi

if [ ! -f "$AGENIX_DIR/strongswan-server-key-pem" ]; then
  echo -e "${RED}Error: Server key not found at $AGENIX_DIR/strongswan-server-key-pem${NC}"
  exit 1
fi

# Create temporary directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"
echo -e "${GREEN}✓${NC} Created temporary directory: $TEMP_DIR"

# Copy server key (reuse existing key)
cp "$AGENIX_DIR/strongswan-server-key-pem" server-key.pem
echo -e "${GREEN}✓${NC} Using existing server private key"

# Create SAN extension config
cat > server-ext.cnf << 'EOF'
[v3_req]
subjectAltName = DNS:vpn.danielramos.me
EOF
echo -e "${GREEN}✓${NC} Created SAN extension config"

# Generate CSR with SAN
openssl req -new \
  -key server-key.pem \
  -subj "/C=ES/O=Home/CN=vpn.danielramos.me" \
  -addext "subjectAltName=DNS:vpn.danielramos.me" \
  -out server.csr

echo -e "${GREEN}✓${NC} Generated CSR with SAN extension"

# Sign certificate with CA (using SHA-384)
openssl x509 -req \
  -in server.csr \
  -CA "$AGENIX_DIR/strongswan-ca-cert-pem" \
  -CAkey "$AGENIX_DIR/strongswan-ca-key-pem" \
  -CAcreateserial \
  -out server-cert.pem \
  -days $CERT_VALIDITY_DAYS \
  -sha384 \
  -extfile server-ext.cnf \
  -extensions v3_req

echo -e "${GREEN}✓${NC} Signed certificate with CA (SHA-384, 10 years validity)"

# Verify certificate
echo ""
echo -e "${YELLOW}Certificate Details:${NC}"
openssl x509 -in server-cert.pem -text -noout | grep -A 5 "Subject:\|CN=\|Subject Alternative Name"

# Verify SAN is present
if openssl x509 -in server-cert.pem -text -noout | grep -q "DNS:vpn.danielramos.me"; then
  echo -e "${GREEN}✓${NC} SAN extension verified!"
else
  echo -e "${RED}✗ Error: SAN extension not found in certificate${NC}"
  exit 1
fi

# Backup original certificate
cp "$AGENIX_DIR/strongswan-server-cert-pem" "$AGENIX_DIR/strongswan-server-cert-pem.bak.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✓${NC} Backed up original certificate"

# Copy new certificate to agenix directory
cp server-cert.pem "$AGENIX_DIR/strongswan-server-cert-pem"
echo -e "${GREEN}✓${NC} Installed new certificate to $AGENIX_DIR/strongswan-server-cert-pem"

# Clean up
cd /
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✓${NC} Cleaned up temporary files"

echo ""
echo -e "${GREEN}=== Regeneration Complete ===${NC}"
echo "The certificate has been regenerated with SAN extension."
echo "strongSwan will use the new certificate on next restart."
echo ""
echo "To apply the changes immediately, run:"
echo -e "${YELLOW}  sudo systemctl restart strongswan-swanctl${NC}"
