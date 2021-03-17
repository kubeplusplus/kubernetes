# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

validate_is_master

# Validate pre-required commands
validate_command kubectl

WORKFLOW_NAME=$1
WORKFLOW_STORAGE=${WORKFLOW_STORAGE:-"$KUBE_FOLDER/workflows"}
WORKFLOW_FOLDER=$WORKFLOW_STORAGE/$WORKFLOW_NAME

if ! [ $WORKFLOW_NAME ]; then echo "[Workflow] WORKFLOW_NAME cannot be blank!";exit; fi
if ! [ -d $WORKFLOW_FOLDER ]; then echo "[Workflow] $WORKFLOW_FOLDER could not be found!";exit; fi

echo "--------------------------------------------------------------------------------"
echo "WORKFLOW_NAME=$WORKFLOW_NAME"
echo "WORKFLOW_FOLDER=$WORKFLOW_FOLDER"
echo "--------------------------------------------------------------------------------"

# Remove resource first
if [ -f $WORKFLOW_FOLDER/resources.yaml ]
then
    kubectl delete -f $WORKFLOW_FOLDER/resources.yaml
    echo "[Workflow] Removed resources"
else 
    echo "[Workflow] $WORKFLOW_FOLDER/resources.yaml is not found!"
fi
echo "--------------------------------------------------------------------------------"

# Remove kubeconfig file
KUBECONFIG_FILE=$WORKFLOW_FOLDER/kubeconfig
if [ -f $KUBECONFIG_FILE ]; then rm -rf $KUBECONFIG_FILE; fi

echo "[Workflow] Done"
echo "--------------------------------------------------------------------------------"