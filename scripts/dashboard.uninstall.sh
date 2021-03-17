# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

validate_is_master

DASHBOARD_NAMESPACE=kubernetes-dashboard

echo "--------------------------------------------------------------------------------"
echo "NAMESPACE=$DASHBOARD_NAMESPACE"
echo "--------------------------------------------------------------------------------"

NAMESPACES=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')
if command -v kubectl &> /dev/null && [[ $NAMESPACES == *"$DASHBOARD_NAMESPACE"* ]]
then
    kubectl delete ns $DASHBOARD_NAMESPACE
fi
echo "[Dashboard] Uninstalled successfully"
echo "--------------------------------------------------------------------------------"
