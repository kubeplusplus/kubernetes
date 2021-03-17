# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

validate_is_master

# Validate pre-required commands
validate_command kubectl

WORKFLOW_NAME=$1
# Template variable could be a name of pre-defined template or a absolute path of your template
TEMPLATE=${2:-"unlimited"}
# Where you save your generated workflow
WORKFLOW_STORAGE=${WORKFLOW_STORAGE:-"$KUBE_FOLDER/workflows"}

if ! [ $WORKFLOW_NAME ]; then echo "[Workflow] WORKFLOW_NAME cannot be blank!";exit; fi

# Use pre-defined template
if [[ "$TEMPLATE" != /* ]]
then
    TEMPLATE=$SOURCE_FOLDER/resources/workflows/templates/$TEMPLATE
fi

# Validate template is exist or not
if ! [ -f $TEMPLATE ];then echo "$TEMPLATE could not be found!";exit; fi
TEMPLATE_NAME=$(basename $TEMPLATE)
NAMESPACE=$WORKFLOW_NAME

echo "--------------------------------------------------------------------------------"
echo "WORKFLOW_NAME=$WORKFLOW_NAME"
echo "TEMPLATE_NAME=$TEMPLATE_NAME"
echo "WORKFLOW_STORAGE=$WORKFLOW_STORAGE"
echo "NAMESPACE=$NAMESPACE"
echo "--------------------------------------------------------------------------------"

# -------------------------- Create resources in Kubernetes --------------------------
WORKFLOW_FOLDER=$WORKFLOW_STORAGE/$WORKFLOW_NAME
# Backup old version of workflow
if [ -d $WORKFLOW_FOLDER ];then mv $WORKFLOW_FOLDER $WORKFLOW_FOLDER.backup-$(date '+%Y%m%d-%H%M%S'); fi
# Make sure template folder is exist
mkdir -p $WORKFLOW_FOLDER

RESOURCE_FILE=$WORKFLOW_STORAGE/$WORKFLOW_NAME/resources.yaml
# Generate template file
cat $TEMPLATE | sed "s/\$WORKFLOW_NAME/$WORKFLOW_NAME/g" | sed "s/\$TEMPLATE_NAME/$TEMPLATE_NAME/g" > $RESOURCE_FILE
# Create resources in Kubernetes
kubectl apply -f $RESOURCE_FILE

# -------------------------- Create Kubernetes context --------------------------
KUBECONFIG_FILE=$WORKFLOW_FOLDER/kubeconfig
CONTEXT_NAME=$WORKFLOW_NAME
CLUSTER_NAME=$WORKFLOW_NAME
CLUSTER_IP=$(get_k8s_cluster_ip)
SA_NAME=$WORKFLOW_NAME-admin

echo "--------------------------------------------------------------------------------"
echo "KUBECONFIG_FILE=$KUBECONFIG_FILE"
echo "CONTEXT_NAME=$CONTEXT_NAME"
echo "CLUSTER_NAME=$CLUSTER_NAME"
echo "CLUSTER_IP=$CLUSTER_IP"
echo "SA_NAME=$SA_NAME"
echo "--------------------------------------------------------------------------------"

# Get service account credentials
SA_SECRET=$(kubectl get sa $SA_NAME -n $NAMESPACE -o jsonpath='{.secrets[*].name}')
kubectl get secret $SA_SECRET -n $NAMESPACE -o jsonpath='{.data.ca\.crt}' | base64 -d > $WORKFLOW_FOLDER/ca.crt
SA_TOKEN=$(kubectl get secret $SA_SECRET -n $NAMESPACE -o jsonpath='{.data.token}' | base64 -d)

# Config cluster of context
kubectl --kubeconfig=$KUBECONFIG_FILE config set-cluster $CLUSTER_NAME \
    --embed-certs=true \
    --server=https://$CLUSTER_IP:6443 \
    --certificate-authority=$WORKFLOW_FOLDER/ca.crt
rm -rf $WORKFLOW_FOLDER/ca.crt
# Config credentials to authenticate 
kubectl --kubeconfig=$KUBECONFIG_FILE config set-credentials $SA_NAME --token=$SA_TOKEN
# Config context
kubectl --kubeconfig=$KUBECONFIG_FILE config set-context $CONTEXT_NAME \
    --cluster=$CLUSTER_NAME \
    --user=$SA_NAME \
    --namespace=$NAMESPACE

kubectl --kubeconfig=$KUBECONFIG_FILE config use-context $CONTEXT_NAME
echo "--------------------------------------------------------------------------------"
kubectl --kubeconfig=$KUBECONFIG_FILE config view
echo "--------------------------------------------------------------------------------"
echo "$ kubectl --kubeconfig=$KUBECONFIG_FILE get secrets"
echo "--------------------------------------------------------------------------------"
kubectl --kubeconfig=$KUBECONFIG_FILE get secrets
echo "--------------------------------------------------------------------------------"
echo "$ kubectl --kubeconfig=$KUBECONFIG_FILE get resourcequota"
echo "--------------------------------------------------------------------------------"
kubectl --kubeconfig=$KUBECONFIG_FILE get resourcequota
echo "--------------------------------------------------------------------------------"
echo "$ kubectl --kubeconfig=$KUBECONFIG_FILE get limitrange"
echo "--------------------------------------------------------------------------------"
kubectl --kubeconfig=$KUBECONFIG_FILE get limitrange
echo "--------------------------------------------------------------------------------"