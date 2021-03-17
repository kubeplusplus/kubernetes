# !/usr/bin/env bash
set -e

export SOURCE_FOLDER="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; cd .. ;pwd -P )"

# Define your script profile
export RC_FILE=${RC_FILE:-"$HOME/.bashrc"}
if [ ! -f "$RC_FILE" ];then echo "$RC_FILE is not exist!"; exit; fi

# Define your kube folder
export KUBE_FOLDER=${KUBE_FOLDER:-"$HOME/.kube"}

# Create a bin folder to store libraries
mkdir -p "$KUBE_FOLDER/libs/bin"

# Make sure our variables are available
export PATH="$PATH:$KUBE_FOLDER/libs/bin"
# Config Kubernetes config file
export KUBECONFIG=$KUBE_FOLDER/kubeconfig

export IS_MASTER="1"
if [[ "$K3S_TOKEN" && "$K3S_URL" ]]; then export IS_MASTER="0"; fi;

function validate_is_master() {
    if [[ "$K3S_TOKEN" && "$K3S_URL" ]]; then echo "[WARN] Please only run this command in master node!";exit; fi
}

function validate_command() {
    if [ -z "$1" ]; then echo "[ERROR] Cannot validate empty command!";exit; fi
    if ! command -v $1 &> /dev/null; then echo "[ERROR] $1 command is required!";exit; fi
}

function ensure_namespace() {
    if [ -z "$1" ]; then echo "[ERROR] Cannot validate empty namespace!";exit; fi

    local NAMESPACES=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')
    if [[ $NAMESPACES != *"$1"* ]]; then kubectl create ns $1 > /dev/null; fi
    wait_for_namespace $1
}

function wait_for_namespace() {
    if [ -z "$1" ]; then echo "[ERROR] Cannot validate empty namespace!";exit; fi

    local NAMESPACE=$(kubectl get ns $1 -o jsonpath='{.metadata.name}' 2> /dev/null)
    while [ "$NAMESPACE" != "$1" ]
    do
        sleep .5
        NAMESPACE=$(kubectl get ns $1 -o jsonpath='{.metadata.name}' 2> /dev/null)
    done
}

function wait_for_pod() {
    if [ -z "$1" ]; then echo "[ERROR] Cannot validate empty pod name!";exit; fi

    local POD_NAME=$1
    local NAMESPACE=${2:-"default"}
    wait_for_namespace $NAMESPACE

    local IS_READY=$(kubectl get pods $POD_NAME -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].ready}')
    local PROGRESS='.'

    while [ "$IS_READY" != "true" ]
    do
        sleep .5
        echo -ne "\r$PROGRESS"
        PROGRESS+='.'

        IS_READY=$(kubectl get pods $POD_NAME -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].ready}')
    done
    if [[ $PROGRESS != "." ]]; then echo -e "\r"; fi
    echo -e "[INFO] $NAMESPACE/$POD_NAME is ready"
}

function get_k8s_cluster_ip() {
    if [ ! $CLUSTER_IP ];then CLUSTER_IP=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}') ;fi
    if [ ! $CLUSTER_IP ];then CLUSTER_IP="127.0.0.1" ;fi
    echo $CLUSTER_IP
}