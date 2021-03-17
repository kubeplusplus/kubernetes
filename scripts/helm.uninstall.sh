# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

validate_is_master

if [ -f "$KUBE_FOLDER/libs/bin/helm" ]
then
    echo "--------------------------------------------------------------------------------"
    helm version
    echo "--------------------------------------------------------------------------------"
    rm -rf "$KUBE_FOLDER/libs/bin/helm"
fi

echo "[Helm] Uninstalled successfully"
echo "--------------------------------------------------------------------------------"
