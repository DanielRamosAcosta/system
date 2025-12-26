#!/@/bin/bash@
# Shell wrapper for Gitea SSH passthrough to Kubernetes
# This script is executed when SSH connections are made to the git user
# It forwards commands to Gitea running in the Kubernetes cluster

export KUBECONFIG=/var/lib/git/.kube/config

# Verify kubeconfig exists and is readable
if [ ! -r "$KUBECONFIG" ]; then
    echo "ERROR: Kubeconfig not found or not readable at $KUBECONFIG"
    echo "Please contact the system administrator."
    exit 1
fi

if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
    # Execute the command through gitea serv in the pod
    # This allows Gitea's pre-receive hooks to properly validate the operation
    # gitea serv will read SSH_ORIGINAL_COMMAND and handle the git operation
    @kubectl@ exec -i -n media gitea-0 -- \
        bash -c "export SSH_ORIGINAL_COMMAND=$(printf '%q' "$SSH_ORIGINAL_COMMAND"); \
                 export GITEA_WORK_DIR=/data/gitea; \
                 export GITEA_CUSTOM=/data/gitea; \
                 export GITEA_CONFIG_PATH=/data/gitea/conf/app.ini; \
                 su git -c '/usr/local/bin/gitea --config=/data/gitea/conf/app.ini serv key-1'"
else
    # If no command was provided, show a friendly message
    echo "Hi there! This is the Gitea SSH interface."
    echo "You've successfully authenticated, but Gitea does not provide shell access."
    echo ""
    echo "To use Gitea, run commands like:"
    echo "  git clone git@ssh.danielramos.me:username/repo.git"
    echo "  git push"
    echo "  git pull"
fi
