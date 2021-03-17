# Pre-defined scripts

## Overview

We are developers, we are lazy! That why I want to put everything I wrote in this tutorial to a set of scripts. Let's review what I did now.

## K3S

### Installation

Path: [scripts/k3s.install.sh](../../scripts/k3s.install.sh)

Options:

- `RC_FILE` (default: $HOME/.bashrc): path to your `runcom file. For example: `.basrc`, `.bash_profile`, `.zshrc` and so forth
- `KUBE_FOLDER` (default: $HOME/.kube): path to folder where you want to put everything of K3S.
- `K3S_TOKEN` and `K3S_URL`: only use those environment variables when you configured worker nodes.

Usage:

- Master Nodes:

  ```bash
  $ export RC_FILE=$HOME/.bashrc
  $ export KUBECONFIG=$HOME/.kube
  $ sudo chmod +x scripts/k3s.install.sh
  $ ./scripts/k3s.install.sh
  ```

- Worker Nodes:
  ```bash
  $ export RC_FILE=$HOME/.bashrc
  $ export KUBECONFIG=$HOME/.kube
  $ export K3S_TOKEN=aaa111bbb222ccc333
  $ export K3S_URL=https://201.121.9.134:6443
  $ sudo chmod +x scripts/k3s.install.sh
  $ ./scripts/k3s.install.sh
  ```

### Remove

Path: [scripts/k3s.uninstall.sh](../../scripts/k3s.uninstall.sh)

There is no difference between Master Nodes and Worker Node when you uninstalled `K3S`. You only need to run one script

```bash
$ sudo chmod +x scripts/k3s.uninstall.sh
$ ./scripts/k3s.uninstall.sh
```

## Helm

### Installation

Path: [scripts/helm.install.sh](../../scripts/helm.install.sh)

Options:

- `RC_FILE` (default: $HOME/.bashrc): path to your `runcom file. For example: `.basrc`, `.bash_profile`, `.zshrc` and so forth
- `KUBE_FOLDER` (default: $HOME/.kube): path to folder where you want to put everything of K3S.
- `HELM_VERSION` (default: **v3.0.2**): choose your `Helm` version by this environment variable

Usage:

```bash
$ sudo chmod +x scripts/helm.install.sh
$ ./scripts/helm.install.sh
```

### Remove

Path: [scripts/helm.install.sh](../../scripts/helm.uninstall.sh)

Usage:

```bash
$ sudo chmod +x scripts/helm.uninstall.sh
$ ./scripts/helm.uninstall.sh
```

## Ingress

### Installation

Path: [scripts/ingress.install.sh](../../scripts/ingress.install.sh)

Options:

- `RC_FILE` (default: $HOME/.bashrc): path to your `runcom file. For example: `.basrc`, `.bash_profile`, `.zshrc` and so forth
- `KUBE_FOLDER` (default: $HOME/.kube): path to folder where you want to put everything of K3S.
- `INGRESS_NAMESPACE` (default: `ingress-nginx`): choose namespace that store your release
- `INGRESS_RELEASE_NAME` (default: `ingress-nginx`): name of your `Helm` release

Usage:

```bash
$ sudo chmod +x scripts/ingress.install.sh
$ ./scripts/ingress.install.sh
```

### Remove

Path: [scripts/ingress.uninstall.sh](../../scripts/ingress.uninstall.sh)

Options:

- `RC_FILE` (default: $HOME/.bashrc): path to your `runcom file. For example: `.basrc`, `.bash_profile`, `.zshrc` and so forth
- `KUBE_FOLDER` (default: $HOME/.kube): path to folder where you want to put everything of K3S.
- `INGRESS_NAMESPACE` (default: `ingress-nginx`): choose namespace that store your release
- `INGRESS_RELEASE_NAME` (default: `ingress-nginx`): name of your `Helm` release
- `INGRESS_NAMESPACE_REMOVABLE` (default: "0"): only delete ignress namespace when we set `INGRESS_NAMESPACE_REMOVABLE=1` explicitly in your command

Usage:

```bash
$ sudo chmod +x scripts/ingress.uninstall.sh
$ ./scripts/ingress.uninstall.sh
# INGRESS_NAMESPACE_REMOVABLE=1 ./scripts/ingress.uninstall.sh # if you want to delete namespace
```

## Dashboard

### Installation

Path: [scripts/dashboard.install.sh](../../scripts/dashboard.install.sh)

Options:

- `RC_FILE` (default: $HOME/.bashrc): path to your `runcom file. For example: `.basrc`, `.bash_profile`, `.zshrc` and so forth
- `KUBE_FOLDER` (default: $HOME/.kube): path to folder where you want to put everything of K3S.

Usage

```bash
$ sudo chmod +x scripts/dashboard.install.sh
$ ./scripts/dashboard.install.sh
```

### Remove

Path: [scripts/dashboard.uninstall.sh](../../scripts/dashboard.uninstall.sh)

Usage

```bash
$ sudo chmod +x scripts/dashboard.uninstall.sh
$ ./scripts/dashboard.uninstall.sh
```

### Access

Path: [scripts/dashboard.access.sh](../../scripts/dashboard.access.sh)

Options:

- `RC_FILE` (default: $HOME/.bashrc): path to your `runcom file. For example: `.basrc`, `.bash_profile`, `.zshrc` and so forth
- `KUBE_FOLDER` (default: $HOME/.kube): path to folder where you want to put everything of K3S.
- `CLUSTER_IP` (default: `automatic detect`): the public IP of you machine, so we can use it to forward access to our cluster

Usage

```bash
$ sudo chmod +x scripts/dashboard.access.sh
$ ./scripts/dashboard.access.sh
```

## Cluster

If you are tired because of repeatable step above, let's use my pre-defined scripts [scripts/cluster.install.sh](../../scripts/cluster.install.sh) and [scripts/cluster.uninstall.sh](../../scripts/cluster.uninstall.sh)

### Installation

```bash
$ export ENABLE_HELM=1 # ignore this option if you don't want to install Helm
$ export ENABLE_INGRESS=1 # ignore this option if you don't want to install Ingress Controller
$ export ENABLE_DASHBOARD=1 # ignore this option if you don't want to install Kubernetes Dashboard
$ sudo chmod +x scripts/cluster.install.sh
$ ./scripts/cluster.install.sh
```

### Remove

```bash
$ sudo chmod +x scripts/cluster.uninstall.sh
$ ./scripts/cluster.uninstall.sh
```
