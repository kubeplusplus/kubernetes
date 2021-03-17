# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

validate_is_master
# Validate pre-required commands
validate_command curl

ARCH=$(dpkg --print-architecture)
HELM_VERSION=${HELM_VERSION:-"v3.0.2"}
HELM_DOWNLOAD_IN="https://get.helm.sh/helm-$HELM_VERSION-linux-$ARCH.tar.gz"
HELM_DOWNLOAD_OUT="/tmp/helm"

echo "--------------------------------------------------------------------------------"
echo "VERSION=$HELM_VERSION"
echo "INPUT=$HELM_DOWNLOAD_IN"
echo "OUTPUT=$HELM_DOWNLOAD_OUT"
echo "--------------------------------------------------------------------------------"

if [ ! -f "$KUBE_FOLDER/libs/bin/helm" ]
then
    sudo rm -rf $HELM_DOWNLOAD_OUT
    mkdir -p $HELM_DOWNLOAD_OUT
    echo "[Helm] Downloading..."
    curl -L $HELM_DOWNLOAD_IN -o "$HELM_DOWNLOAD_OUT/helm.tar.gz"

    echo "[Helm] Extracting..."
    gzip -f -d "$HELM_DOWNLOAD_OUT/helm.tar.gz"
    tar -xf "$HELM_DOWNLOAD_OUT/helm.tar" -C $HELM_DOWNLOAD_OUT

    echo "[Helm] Installing..."
    sudo mv "$HELM_DOWNLOAD_OUT/linux-$ARCH/helm" "$KUBE_FOLDER/libs/bin/helm"
    sudo chmod +x "$KUBE_FOLDER/libs/bin/"
    sudo chmod +x "$KUBE_FOLDER/libs/bin/helm"
    rm -rf $HELM_DOWNLOAD_OUT
fi

echo "[Helm] Installed successfully"
echo "--------------------------------------------------------------------------------"
helm version
echo "--------------------------------------------------------------------------------"
