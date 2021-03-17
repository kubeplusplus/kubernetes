# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

./scripts/k3s.install.sh

ENABLE_HELM=${ENABLE_HELM:-"0"}
ENABLE_INGRESS=${ENABLE_INGRESS:-"0"}
ENABLE_DASHBOARD=${ENABLE_DASHBOARD:-"0"}

if [[ $IS_MASTER == "1" && $ENABLE_HELM == "1" ]]; then ./scripts/helm.install.sh; fi
if [[ $IS_MASTER == "1" && $ENABLE_INGRESS == "1" ]]; then ./scripts/ingress.install.sh; fi
if [[ $IS_MASTER == "1" && $ENABLE_DASHBOARD == "1" ]]; then ./scripts/dashboard.install.sh; fi
if [[ $IS_MASTER == "1" && $ENABLE_DASHBOARD == "1" ]]; then ./scripts/dashboard.access.sh; fi