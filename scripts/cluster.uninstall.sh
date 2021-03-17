# !/usr/bin/env bash
set -e

# Acquire utils
SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$SCRIPT_PATH/__utils.sh"

if [ $IS_MASTER == "1" ]; then ./scripts/dashboard.uninstall.sh; fi
if [ $IS_MASTER == "1" ]; then ./scripts/ingress.uninstall.sh; fi
if [ $IS_MASTER == "1" ]; then ./scripts/helm.uninstall.sh; fi

./scripts/k3s.uninstall.sh