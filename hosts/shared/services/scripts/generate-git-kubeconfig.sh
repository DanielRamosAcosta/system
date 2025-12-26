#!/@/bin/bash@
# Generate kubeconfig for git user from ServiceAccount token
# Executed by cron every 5 minutes

set -euo pipefail

KUBECONFIG_DIR="/var/lib/git/.kube"
KUBECONFIG_FILE="$KUBECONFIG_DIR/config"
TEMP_KUBECONFIG="$KUBECONFIG_FILE.tmp"

echo "[$(date)] Generating kubeconfig for git-ssh ServiceAccount..."

# Wait for K3s to be ready (important at boot time)
timeout=60
while [ $timeout -gt 0 ]; do
  if @kubectl@ --kubeconfig=/etc/rancher/k3s/k3s.yaml \
     get serviceaccount -n media git-ssh &>/dev/null; then
    break
  fi
  echo "[$(date)] Waiting for K3s and ServiceAccount to be ready..."
  sleep 2
  timeout=$((timeout - 2))
done

if [ $timeout -le 0 ]; then
  echo "[$(date)] ERROR: Timeout waiting for K3s or ServiceAccount git-ssh"
  exit 1
fi

# Create ServiceAccount token with 48 hour expiry
TOKEN=$(@kubectl@ --kubeconfig=/etc/rancher/k3s/k3s.yaml \
        create token git-ssh \
        -n media \
        --duration=48h 2>&1)

if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to create token: $TOKEN"
  exit 1
fi

# Extract cluster CA certificate
CA_CERT=$(@kubectl@ --kubeconfig=/etc/rancher/k3s/k3s.yaml \
          config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# API server endpoint
API_SERVER="https://localhost:6443"

# Create kubeconfig directory if it doesn't exist
mkdir -p "$KUBECONFIG_DIR"

# Generate kubeconfig file
cat > "$TEMP_KUBECONFIG" <<EOF
apiVersion: v1
kind: Config
clusters:
- name: k3s
  cluster:
    certificate-authority-data: $CA_CERT
    server: $API_SERVER
contexts:
- name: git-ssh
  context:
    cluster: k3s
    namespace: media
    user: git-ssh
current-context: git-ssh
users:
- name: git-ssh
  user:
    token: $TOKEN
EOF

# Set restrictive permissions before moving to final location
chmod 600 "$TEMP_KUBECONFIG"
chown git:git "$TEMP_KUBECONFIG"

# Atomic move to final location
mv "$TEMP_KUBECONFIG" "$KUBECONFIG_FILE"

echo "[$(date)] ✓ Kubeconfig generated at $KUBECONFIG_FILE"

# Verify the kubeconfig works
if @kubectl@ --kubeconfig="$KUBECONFIG_FILE" \
   exec -n media gitea-0 -- echo "test" &>/dev/null; then
  echo "[$(date)] ✓ Kubeconfig verification successful"
else
  echo "[$(date)] ⚠ WARNING: Kubeconfig verification failed"
  exit 1
fi
