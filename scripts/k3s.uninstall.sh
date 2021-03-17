# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

K3S_SERVER_UNINSTALL_SCRIPT="/usr/local/bin/k3s-uninstall.sh"
K3S_AGENT_UNINSTALL_SCRIPT="/usr/local/bin/k3s-agent-uninstall.sh"

# Uninstall K3S server
if [ -f "$K3S_SERVER_UNINSTALL_SCRIPT" ];then bash -c "$K3S_SERVER_UNINSTALL_SCRIPT"; fi

# Uninstall K3S agent
if [ -f "$K3S_AGENT_UNINSTALL_SCRIPT" ];then bash -c "$K3S_AGENT_UNINSTALL_SCRIPT"; fi

# Remove kubernetes folder
if [ -d $KUBE_FOLDER ]; then mv $KUBE_FOLDER $KUBE_FOLDER.uninstall-$(date '+%Y%m%d-%H%M%S'); fi
echo "[K3S] Uninstalled successfully"
echo "--------------------------------------------------------------------------------"
