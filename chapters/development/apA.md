# Secret Management in GitOps

## Requirements

- cURL
- K8S cluster
- GitHub Repository
- Flux CD

## Overview

When I were done with GitOps, the first question I wonder is how I manage my secret? Should I handle it by my hand or save it to somewhere and by somehow I can use it by the safe way? Finally, I found that FluxCD offers some way to do that. I chose [Sealed Secrets](https://toolkit.fluxcd.io/guides/sealed-secrets/) becuase it is easy to use.

## Installation

### Installing Operator

You have to install the operator that will decrypt your secrets in your cluster. Because we are using GitOps, so it is suitable to use GitOps to deploy our manifests.

Define the `Source` from by `HelmRepository` at `clusters/demo/sealed-secrets/source.yaml`

```YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: bitnami
  namespace: flux-system
spec:
  interval: 1h0m0s
  url: https://bitnami-labs.github.io/sealed-secrets
```

Then create the `HelmRelease` at `clusters/demo/sealed-secrets/release.yaml`

```YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: sealed-secrets
  namespace: flux-system
spec:
  chart:
    spec:
      chart: sealed-secrets
      sourceRef:
        kind: HelmRepository
        name: bitnami
      version: "1.13.2"
  interval: 1h0m0s
  releaseName: sealed-secrets
  targetNamespace: flux-system
```

Finally, commit your resources to GitOps repository and wait for all resources were applied.

### Installing Client

Sealed Secrets is tool that allow you to encrypt your secrets. Install it is easy by command

```bash
export SEALED_SECRET_VERSION=v0.14.0
curl -L https://github.com/bitnami-labs/sealed-secrets/releases/download/$SEALED_SECRET_VERSION/kubeseal-linux-amd64 -o ~/.kube/libs/bin/kubeseal
sudo chmod +x ~/.kube/libs/bin/kubeseal
```

### Prepare secrets

First, you have to pull out the public key that is used to encrypt your secrets. It is **safe** to save it to your GitOps repository (you should do that, so other teammates can use it to encrypt their data too)

```bash
$ mkdir keys
$ kubeseal --fetch-cert \
--controller-name=sealed-secrets \
--controller-namespace=flux-system \
> keys/pub-sealed-secrets.pem
```

Second, create a demo secret with `username` and `password`

```bash
kubectl -n default create secret generic basic-auth \
--from-literal=user=admin \
--from-literal=password=change-me \
--dry-run=client \
-o yaml > basic-auth.yaml
```

Third, encrypt your secret by `kubeseal`

```bash
$ kubeseal --format=yaml --cert=keys/pub-sealed-secrets.pem \
< basic-auth.yaml > secrets/basic-auth-sealed.yaml
rm -rf basic-auth.yaml
```

<details>
  <summary>Example encrypt file</summary>

```YAML
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: basic-auth
  namespace: default
spec:
  encryptedData:
    password: AgAx6nGCpf/9ARfOyUSQnjvSgNjzxyIuaG9RXx1+riaoO054IeGVc80VXXcjt8XDnnkFHYOHyBwu11Dk8SpMKpxxyJ/TLEtsaXeIK8dhPDuZDIbTNJv8HtqQnURDbHr2llhBhgLbEAncWvgp0hqxGUVz+CZ52kKAvOPrN60Ypxsfy6knl4j/QnLlefuNchrdzS9jceN5OM+sc0LIyww+nz9INivwa5j+GKyBk+F4qtIrF0ngy/RRlcvjY156s2gajJIOVnHubfanlkF7ABRUFsK4yOgWCuaPq27YcEj80ASQYD+Q+AIFjzhkySN+2CCOjCii6HMycJdSDQe1sGOOLfIO3sARoUmO4+8p8vvLOILamuHfElyWlEJe6wiYfjcvcwfaOMsvWK7crjLqZ5w7ljtov/I8i5qGobD0Id1HQS67dep9bNFZO/2unT4f9ZiK9MPt9Kj0I9jc/JpUxD+LkaMQ5X8CRia/NmtLFLLGjKq2hGe9KkUswiyAELiTQQPlmPIHWn34BerxhwkTVv3U/QlJH+mJk1ITrU/lxyiwNu7RKtKTMzBkhaBun6nhQUHjjSpuqqOV4BUSvCHshDwIEZhFsg7cUFiMBMs96Y021QjunEfSzl4szb4cGSu2CBF12jkgSYr4e4rS2A9r7lEAO0HGGwwX4rmIY64mnTJk9fNy9hCd+suRBLccQUfeGSWgE1jvcZ45OejcXI8=
    user: AgBu3ee2xGF6MD7CbOes4mPTYCQNHr/CS51TtMdyn62FBbjGY1hRPnSTEhT7yF7gHiguRqO3Cow3Oqkb/FHbdeBNBAM6RCPZZ5f7DFyF5F1QUeI8kMRikW+wOJO6RMajc+LA22gAqtafiO5W15BpGLMWRmpUwtDipI5F53r+cFjnbiau4PlAldBzQAOBYPBRoltxNw4N1wkGqbk6n7nlyOeIuLiIonvD3Sih9gnWQwKAFeeAdT+tToIrdzyAdnAh3XEPM6uUrOi3JVNqjKDjzoeNQEE3ZA6fKe+/gHkvn6dNrFI4HV8yS9t2LIQ158qo7R4JNh7nmlutRXQw2EeKSB05wcs+4hYHDVVr82nv/5gFT7RcpNKDjd9pzK0EfY4g1OyzKGdWSO8DYe9dWKP4zyNMEgsobuqC8dpsMUVb1EOOZrkFpq/HwnWXxtR2MIRfGainSpJuHLLxqxnHE/nDdhoZIRqhzP9lmrYoaCWrtYQP6zdIEPEDP5SScmiszHTHK07oAljm21pGMtqTlY33/EYnMJjO9I2QFqXUZBx+4yGu8sulrHf7M0zVbVs3/S3bpo129/RkAQo0MYQ/LVyUyW8Rg5hUKBCkthwgkMPxo2FOd13lJR+iID2vzk03z9hEV8EtTaUSsYgegsvwzj3mDV/SiIWLAGJ0lZTYA1jxLUeQUvN3nRmtkb4yqvlItYpPdC7uMlefdg==
  template:
    metadata:
      creationTimestamp: null
      name: basic-auth
      namespace: default
```

</details>

Finally, create the secret in your cluster by command

```bash
$ kubectl apply -f secrets/basic-auth-sealed.yaml
sealedsecret.bitnami.com/basic-auth created
```

You can verify your secret is created in your cluster successfully by command

```bash
$ kubectl describe secrets basic-auth

Name:         basic-auth
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  9 bytes
user:      5 bytes
```
