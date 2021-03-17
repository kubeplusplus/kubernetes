# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

validate_is_master

# Validate pre-required commands
validate_command kubectl

DASHBOARD_NAMESPACE=kubernetes-dashboard
DASHBOARD_DEPLOYMENT_NAME=kubernetes-dashboard

echo "--------------------------------------------------------------------------------"
echo "NAMESPACE=$DASHBOARD_NAMESPACE"
echo "DEPLOYMENT=$DASHBOARD_DEPLOYMENT_NAME"
echo "--------------------------------------------------------------------------------"

function get_pod_name() {
    echo $(kubectl get pods -n $DASHBOARD_NAMESPACE -l k8s-app=kubernetes-dashboard -o jsonpath='{.items[*].metadata.name}')
}

if [[ $(get_pod_name) != *"$DEPLOYMENT_NAME"* ]]
then
    echo "[ERROR] Dashboard was not deployed yet!";exit;
fi

wait_for_pod $(get_pod_name) $DASHBOARD_NAMESPACE

kubectl apply -f "$SOURCE_FOLDER/resources/dashboard-account.yaml"
echo ""
echo "[Dashboard] Please use token bellow to access your cluster dashboard"
echo "--------------------------------------------------------------------------------"
kubectl -n $DASHBOARD_NAMESPACE describe secret dashboard-admin | grep ^token

CLUSTER_IP=$(get_k8s_cluster_ip)
echo ''
echo "[Dashboard] Access your dashboard at https://$CLUSTER_IP:10443/#/overview?namespace=_all"
echo "--------------------------------------------------------------------------------"
kubectl port-forward deployment/$DASHBOARD_DEPLOYMENT_NAME 10443:8443 --address 0.0.0.0 -n $DASHBOARD_NAMESPACE

echo "--------------------------------------------------------------------------------"