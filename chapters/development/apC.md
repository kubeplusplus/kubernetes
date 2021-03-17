# Manage Workflows

## Overview

In [Chapter 6: Setup Workflow](./06.setup-workflow.md), I introduced first look about Kubernetes workflow to you. Now, we are going to get deep in to how to manage our workflow by my pre-defined script.

## Generate Workflow

### Overview

Now, we need to determine what we need and what we have to do. The workflow will need some resources

- A name, absolutely!
- A Namespace
- A Service Account
- RBAC resources
- Resources Quota (Optional)
- A `kubeconfig` file that contains your context, service account token and the server.

OK! Let's think, let's think! Should we combine `Namespace`, `Service Account`, `RBAC resources` and `Resources Quota` to one file and use `kubectl` to create them?
It makes sense, right? So, let's create YAML template file that contain all Kubernetes resources.

Here is an example of template file:

<details>
  <summary>resources/workflows/templates/minimum</summary>
  
```YAML
apiVersion: v1
kind: Namespace
metadata:
  name: $WORKFLOW_NAME
  labels:
    workflow-template: $TEMPLATE_NAME
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $WORKFLOW_NAME-admin
  namespace: $WORKFLOW_NAME
  labels:
    workflow-template: $TEMPLATE_NAME
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $WORKFLOW_NAME-admin
  namespace: $WORKFLOW_NAME
  labels:
    workflow-template: $TEMPLATE_NAME
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $WORKFLOW_NAME-admin
  namespace: $WORKFLOW_NAME
  labels:
    workflow-template: $TEMPLATE_NAME
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $WORKFLOW_NAME-admin
subjects:
  - kind: ServiceAccount
    name: $WORKFLOW_NAME-admin
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: $WORKFLOW_NAME-resource-quota
  namespace: $WORKFLOW_NAME
  labels:
    workflow-template: $TEMPLATE_NAME
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: $WORKFLOW_NAME-limit-range
  namespace: $WORKFLOW_NAME
  labels:
    workflow-template: $TEMPLATE_NAME
spec:
  limits:
    - default:
        cpu: 2
        memory: 1Gi
      defaultRequest:
        cpu: 1
        memory: 512Mi
      type: Container
```
</details>

But we can't use that file to create resources of Kubernetes, we have to **combine** it to a real YAML file by command

```bash
$ export TEMPLATE=resources/workflows/templates/minimum
$ export TEMPLATE_NAME=minimum
$ export RESOURCE_FILE=$HOME/.kube/workflows/$WORKFLOW_NAME/resources.yaml
$ cat $TEMPLATE | sed "s/\$WORKFLOW_NAME/$WORKFLOW_NAME/g" | sed "s/\$TEMPLATE_NAME/$TEMPLATE_NAME/g" > $RESOURCE_FILE
```

### Generation Script

All of steps above is what I did in our script [scripts/workflow.generate.sh](../../scripts/workflow.generate.sh). Let's me explain how you use it to handle workflow management.

First, chose a workflow name (example: `qa-test`)

Second, chose a template that you defined it before. You can re-use my pre-define template by name (`minimum` and `unlimited`) or use a **absolute path** to your template file. For example: `/home/ubuntu/templates/custom-template`.

Third, choose where you want to save workflow's manifest by `WORKFLOW_STORAGE`. By default, it is `$HOME/.kube/workflows`

Let's create an example workflow with name `qa-test` by template `minimum`

```bash
$ sudo chmod +x scripts/workflow.generate.sh
$ export WORKFLOW_STORAGE=$HOME/.kube/workflows
$ ./scripts/workflow.generate.sh qa-test minimum
```

Here is example output

<details>
  <summary>./scripts/workflow.generate.sh qa-test</summary>

```bash
--------------------------------------------------------------------------------
WORKFLOW_NAME=qa-test
TEMPLATE_NAME=minimum
WORKFLOW_STORAGE=/home/ubuntu/.kube/workflows
NAMESPACE=qa-test
--------------------------------------------------------------------------------
namespace/qa-test created
serviceaccount/qa-test-admin created
role.rbac.authorization.k8s.io/qa-test-admin created
rolebinding.rbac.authorization.k8s.io/qa-test-admin created
resourcequota/qa-test-resource-quota created
limitrange/qa-test-limit-range created
--------------------------------------------------------------------------------
KUBECONFIG_FILE=/home/ubuntu/.kube/workflows/qa-test/kubeconfig
CONTEXT_NAME=qa-test
CLUSTER_NAME=qa-test
CLUSTER_IP=192.168.64.4
SA_NAME=qa-test-admin
--------------------------------------------------------------------------------
Cluster "qa-test" set.
User "qa-test-admin" set.
Context "qa-test" created.
Switched to context "qa-test".
--------------------------------------------------------------------------------
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.64.4:6443
  name: qa-test
contexts:
- context:
    cluster: qa-test
    namespace: qa-test
    user: qa-test-admin
  name: qa-test
current-context: qa-test
kind: Config
preferences: {}
users:
- name: qa-test-admin
  user:
    token: REDACTED
--------------------------------------------------------------------------------
$ kubectl --kubeconfig=/home/ubuntu/.kube/workflows/qa-test/kubeconfig get secrets
--------------------------------------------------------------------------------
NAME                        TYPE                                  DATA   AGE
default-token-vvt8p         kubernetes.io/service-account-token   3      3s
qa-test-admin-token-r66sl   kubernetes.io/service-account-token   3      3s
--------------------------------------------------------------------------------
$ kubectl --kubeconfig=/home/ubuntu/.kube/workflows/qa-test/kubeconfig get resourcequota
--------------------------------------------------------------------------------
NAME                     AGE   REQUEST                                     LIMIT
qa-test-resource-quota   4s    requests.cpu: 0/1, requests.memory: 0/1Gi   limits.cpu: 0/2, limits.memory: 0/2Gi
--------------------------------------------------------------------------------
$ kubectl --kubeconfig=/home/ubuntu/.kube/workflows/qa-test/kubeconfig get limitrange
--------------------------------------------------------------------------------
NAME                  CREATED AT
qa-test-limit-range   2021-01-30T13:34:00Z
--------------------------------------------------------------------------------
```

</details>

Verify your manifests are exist

```bash
$ cat $HOME/.kube/workflows/qa-test/kubeconfig
$ cat $HOME/.kube/workflows/qa-test/resources.yaml
```

### Destroy Script

You can use script at [scripts/workflow.destroy.sh](../../scripts/workflow.destroy.sh) to destroy your workflow.

```bash
$ export WORKFLOW_STORAGE=$HOME/.kube/workflows
$ ./scripts/workflow.destroy.sh qa-test
```

<details>

  <summary>./scripts/workflow.destroy.sh qa-test</summary>

```bash

WORKFLOW_NAME=qa-test
WORKFLOW_FOLDER=/home/ubuntu/.kube/workflows/qa-test
--------------------------------------------------------------------------------
namespace "qa-test" deleted
serviceaccount "qa-test-admin" deleted
role.rbac.authorization.k8s.io "qa-test-admin" deleted
rolebinding.rbac.authorization.k8s.io "qa-test-admin" deleted
resourcequota "qa-test-resource-quota" deleted
limitrange "qa-test-limit-range" deleted
[Workflow] Removed resources
--------------------------------------------------------------------------------
[Workflow] Done
--------------------------------------------------------------------------------
```

</details>
