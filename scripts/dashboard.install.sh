# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

validate_is_master

# Validate pre-required commands
validate_command curl
validate_command kubectl
validate_command helm

DASHBOARD_NAMESPACE=kubernetes-dashboard
DASHBOARD_GITHUB_URL=https://github.com/kubernetes/dashboard/releases
DASHBOARD_VERSION=$(curl -w '%{url_effective}' -I -L -s -S ${DASHBOARD_GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')

echo "--------------------------------------------------------------------------------"
echo "NAMESPACE=$DASHBOARD_NAMESPACE"
echo "VERSION=$DASHBOARD_VERSION"
echo "--------------------------------------------------------------------------------"
ensure_namespace $DASHBOARD_NAMESPACE

function get_pod_name() {
    echo $(kubectl get pods -n $DASHBOARD_NAMESPACE -l k8s-app=kubernetes-dashboard -o jsonpath='{.items[*].metadata.name}')
}

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml
echo "[Dashboard] Installed successfully"
echo "--------------------------------------------------------------------------------"

wait_for_pod $(get_pod_name) $DASHBOARD_NAMESPACE
kubectl get pods -n $DASHBOARD_NAMESPACE
echo "--------------------------------------------------------------------------------"