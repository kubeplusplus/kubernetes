# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

# Validate pre-required commands
validate_command curl

# Only install new K3S if it was not installed
if ! command -v k3s &> /dev/null
then
    # Backup that file if it's exist
    if [ -f $KUBECONFIG ]; then mv $KUBECONFIG $KUBECONFIG.old-$(date '+%Y%m%d-%H%M%S'); fi
    
    # Install K3S sever if both K3S_TOKEN and K3S_URL are not defined
    if ! [[ "$K3S_TOKEN" && "$K3S_URL" ]]
    then
        curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig $KUBECONFIG --write-kubeconfig-mode 644 --disable traefik
    # Or install K3S agent
    else
        curl -sfL https://get.k3s.io | sh -
    fi
fi

echo "[K3S] Installed successfully!"
echo "--------------------------------------------------------------------------------"
k3s -v
echo "--------------------------------------------------------------------------------"

# Only configure kubernetes context in server node
if [ $IS_MASTER == "1" ]
then
    kubectl version
    echo "--------------------------------------------------------------------------------"

    if ! grep -q KUBECONFIG "$RC_FILE"
    then
        echo -en "\n# Kubernetes\n" >> $RC_FILE
        echo -en "export KUBECONFIG=$KUBECONFIG\n\n" >> $RC_FILE
    fi

    if ! grep -q "PATH=\"\$PATH:$KUBE_FOLDER/libs/bin\"" "$RC_FILE"
    then
        echo -en "# Kubernetes tools execute path\n" >> $RC_FILE
        echo -en "if [ -d \"$KUBE_FOLDER/libs/bin\" ];then PATH=\"\$PATH:$KUBE_FOLDER/libs/bin\"; fi\n" >> $RC_FILE
    fi

    echo "[K3S] Configured successfully"
    echo "--------------------------------------------------------------------------------"
fi