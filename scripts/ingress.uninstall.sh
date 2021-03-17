# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

validate_is_master

# Validate pre-required commands
validate_command kubectl
validate_command helm

INGRESS_NAMESPACE=${INGRESS_NAMESPACE:-"ingress-nginx"}
INGRESS_NAMESPACE_REMOVABLE=${INGRESS_NAMESPACE_REMOVABLE:-"0"}
INGRESS_RELEASE_NAME=${INGRESS_RELEASE_NAME:-"ingress-nginx"}

echo "--------------------------------------------------------------------------------"
echo "NAMESPACE=$INGRESS_NAMESPACE"
echo "RELEASE_NAME=$INGRESS_RELEASE_NAME"
echo "--------------------------------------------------------------------------------"

function get_pod_name() {
    echo $(kubectl get pods -n $INGRESS_NAMESPACE -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[*].metadata.name}')
}

if command -v kubectl &> /dev/null
then
    POD_NAME=$(get_pod_name)
    if [[ $POD_NAME == "$INGRESS_RELEASE_NAME"* ]]
    then
        helm uninstall $INGRESS_RELEASE_NAME -n $INGRESS_NAMESPACE
        helm repo remove ingress-nginx

        # Remove redundnat resources
        kubectl delete configmap "ingress-controller-leader-nginx" -n $INGRESS_NAMESPACE

        NGINX_ADMISSION_NAME="ingress-nginx-admission"
        if [ $INGRESS_NAMESPACE != "ingress-nginx" ];then NGINX_ADMISSION_NAME="$INGRESS_NAMESPACE-$NGINX_ADMISSION_NAME";fi
        kubectl delete secret $NGINX_ADMISSION_NAME -n $INGRESS_NAMESPACE

        if [ $INGRESS_NAMESPACE_REMOVABLE == "1" ];then kubectl delete ns $INGRESS_NAMESPACE;fi
    fi
fi

echo "[Ingress] Uninstalled successfully"
echo "--------------------------------------------------------------------------------"
