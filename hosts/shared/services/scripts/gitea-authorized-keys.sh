#!/@/bin/bash@
# AuthorizedKeysCommand wrapper for Gitea SSH authentication
# Fetches SSH keys from Gitea running in Kubernetes

export KUBECONFIG=/var/lib/git/.kube/config

# Verify kubeconfig exists and is readable
if [ ! -r "$KUBECONFIG" ]; then
    # Silently fail - SSH will try other auth methods
    exit 1
fi

# Execute gitea keys command as the git user inside the pod to avoid permission errors
# Arguments: $1 = username, $2 = key type, $3 = public key
OUTPUT=$(@kubectl@ exec -i -n media gitea-0 -- \
  su - git -c "/usr/local/bin/gitea keys -e git -u $(printf '%q' "$1") -t $(printf '%q' "$2") -k $(printf '%q' "$3")" 2>&1)

EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  echo "$OUTPUT"
else
  echo ""
fi
