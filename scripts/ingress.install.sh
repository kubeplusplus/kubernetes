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

INGRESS_NAMESPACE=${INGRESS_NAMESPACE:-"ingress-nginx"}
INGRESS_RELEASE_NAME=${INGRESS_RELEASE_NAME:-"ingress-nginx"}

echo "--------------------------------------------------------------------------------"
echo "NAMESPACE=$INGRESS_NAMESPACE"
echo "RELEASE_NAME=$INGRESS_RELEASE_NAME"
echo "--------------------------------------------------------------------------------"
ensure_namespace $INGRESS_NAMESPACE

function get_pod_name() {
    echo $(kubectl get pods -n $INGRESS_NAMESPACE -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[*].metadata.name}')
}

if [[ $(get_pod_name) != "$INGRESS_RELEASE_NAME"* ]]
then
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    helm install $INGRESS_RELEASE_NAME ingress-nginx/ingress-nginx -n $INGRESS_NAMESPACE
fi
echo "[Ingress] Installed successfully"
echo "--------------------------------------------------------------------------------"

wait_for_pod $(get_pod_name) $INGRESS_NAMESPACE
kubectl exec -it $(get_pod_name) -n $INGRESS_NAMESPACE -- /nginx-ingress-controller --version
