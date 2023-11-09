---
title: "Easy steps to install K3s with SSL certificate by traefik, cert manager and Let’s Encrypt"
layout: post
date: 2023-09-24 00:00
image: https://miro.medium.com/v2/resize:fit:4800/format:webp/1*QjNtMXMX2E5oHWF4lrKAbw.png
headerImage: false
tag:
- kubernetes
- ssl
- traefik
category: blog
author: albertcolom
description: How to install k3s + Traefik + CertManager + LetsEncrypt.
---

![Kubernetes + Traefik + CertManager + LetsEncrypt](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*QjNtMXMX2E5oHWF4lrKAbw.png)

How to install k3s + Traefik + CertManager + LetsEncrypt

#### Why use k3s?

_k3s_ is a lightweight _Kubernetes_ distribution designed to be minimal and efficient, making it well-suited for resource-constrained environments and use cases where simplicity and ease of deployment are important. It was created by _Rancher_ Labs and is intended to simplify the installation and management of Kubernetes clusters.

In this example use _k3s_ with _Traefik_ ingress controller so it’s a default by _K3s_ and it’s a lightweight, easy, and fast solution, but if you prefer another one feel free to use it.

#### Why use cert manager?

Using _cert-manager_ on _Kubernetes_ simplifies **SSL/TLS** certificate management, automates the renewal process, integrates seamlessly with _Kubernetes_ resources, and provides the flexibility to work with various certificate issuers. This results in enhanced security and reduced operational overhead for securing your Kubernetes applications.

---

### 1. Install k3s

{% highlight bash %}
curl -sfL https://get.k3s.io | sh -
{% endhighlight %}

If you want to have access to the _k3s_ cluster outside the node, you can use the following parameter when creating the cluster `--tls-san`.

{% highlight bash %}
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san <public ip address or hostname>" sh -
{% endhighlight %}

By default, you do not have to execute permissions on k3.conf to resolve you need to move the file and give it the necessary permissions.

> **NOTE** : It’s not recommended to give permissions to the original file.

{% highlight bash %}
mkdir $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chmod 644 $HOME/.kube/config

export KUBECONFIG=~/.kube/config
{% endhighlight %}

> You can add `KUBECONFIG=~/.kube/config` to your `~/.profile` or `~/.bashrc` to make it persist on reboot.

---

### 2. Install helm (optional)

This step is completely optional in order to follow the tutorial but highly recommended.

Helm is a package manager for _Kubernetes_ that simplifies the deployment and management of applications in _Kubernetes_ clusters.

Install _Helm_ on _K3s_ is really easy, just execute the script and you don’t need to modify any config !

{% highlight bash %}
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
{% endhighlight %}

---

### 3. Install cert manager

Mainly, we have two ways to install with `helm` or with `kubectl`. Personally I prefer to use the `helm` package manager with all the advantages that comes with it.

#### Option 1: Install by Helm (recommended)

Add the oficial repository on _Helm_

{% highlight bash %}
helm repo add jetstack https://charts.jetstack.io
{% endhighlight %}

Update your local _Helm_ chart repository

{% highlight bash %}
helm repo update
{% endhighlight %}

And install de _cert-manager_ with namespace _cert-manager_

{% highlight bash %}
helm install \
 cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
{% endhighlight %}

> **_NOTE_** _: You can find the all config parameters on the oficial chart page:_ [https://artifacthub.io/packages/helm/cert-manager/cert-manager](https://artifacthub.io/packages/helm/cert-manager/cert-manager#configuration)

#### Option 2: Install by kubectl

{% highlight bash %}
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.4/cert-manager.crds.yaml
{% endhighlight %}

#### 3.1 Verify the cert manager installation

{% highlight bash %}
kubectl -n cert-manager get pod
{% endhighlight %}

![cert-manager pods](https://cdn-images-1.medium.com/max/1024/1*Aulz7KN5eojK7xo4xeSNcA.png)

---

### 4. Create the ClusterIssuer resource

Create _ClusterIssuer_ for `staging` environment

{% highlight yaml %}
# cluster-issuer-staging.yaml

apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
  namespace: default
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: <YOUR_EMAIL> # replace for your valid email
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - selector: {}
      http01:
        ingress:
          class: traefik
{% endhighlight %}

{% highlight bash %}
kubectl apply -f cluster-issuer-staging.yaml
{% endhighlight %}

Create ClusterIssuer for `production` environment

{% highlight yaml %}
# cluster-issuer-production.yaml

apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
  namespace: default
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: <YOUR_EMAIL> # replace for your valid email
    privateKeySecretRef:
      name: letsencrypt-production
    solvers:
    - selector: {}
      http01:
        ingress:
          class: traefik
{% endhighlight %}

{% highlight bash %}
kubectl apply -f cluster-issuer-production.yaml
{% endhighlight %}

#### Verify that it has been properly applied

{% highlight bash %}
kubectl get ClusterIssuer -A
{% endhighlight %}

![kubernetes ClusterIssuer](https://cdn-images-1.medium.com/max/1024/1*xIB9syzqvr_SxSnzD7fqMQ.png)

And check the status of _ClusterIssuer_

{% highlight bash %}
kubectl describe clusterissuer letsencrypt-staging
kubectl describe clusterissuer letsencrypt-production
{% endhighlight %}

---

### 5. Let’s play!

Finally we are going to create our certificate

#### 5.1 Create a dummy application

In this step just create a very basic dummy `nginx` application, if you already have an application you can go to the next step.

Create a deployment using a default image from `nginx:alpine`

{% highlight bash %}
kubectl create deployment nginx --image nginx:alpine
{% endhighlight %}

Show the deployments status

{% highlight bash %}
kubectl get deployments
{% endhighlight %}

![kubernetes deployments](https://cdn-images-1.medium.com/max/1024/1*qC-IpG0HbWLT3E7aiHgJcg.png)

{% highlight bash %}
kubectl describe deployment nginx
{% endhighlight %}

Expose the server at port 80

{% highlight bash %}
kubectl expose deployment nginx --port 80 --target-port 80
{% endhighlight %}

Check that the service is correct and running

{% highlight bash %}
kubectl get svc
{% endhighlight %}

![kubernetes services](https://cdn-images-1.medium.com/max/1024/1*3Sig9s2Ni8KsVQzWwLW8VQ.png)

#### 5.2 Create a ingress traefik controller

Define the _trafik_ ingress with the `cert-manager` annotations and the `tsl` section to be able to manage our certificate.

{% highlight yaml %}
# ingress ingress-nginx.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-production
    kubernetes.io/ingress.class: traefik
  labels:
    app: nginx
  name: nginx
  namespace: default
spec:
  rules:
  - host: example.com # Change by your domain
    http:
      paths:
      - backend:
          service:
            name: nginx
            port: 
              number: 80
        path: /
        pathType: Prefix  
  tls:
  - hosts:
    - example.com # Change by your domain
    secretName: example-com-tls
{% endhighlight %}

{% highlight bash %}
kubectl apply -f ingress-nginx.yaml
{% endhighlight %}

Verify that the certificate has actually been created

{% highlight bash %}
kubectl get cert -n default
{% endhighlight %}

> **_NOTE_** : _I change the host_ `example.com` _to letsencrypt-k3s.albertcolom.com and change_ `example-com-tls` _to letsencryptk3s-albertcolom-com-tls ._

![kubernetes certificates](https://cdn-images-1.medium.com/max/1024/1*XPQDwgtxq2cMFl3ADPkhYQ.png)

You can show the valid certificated by Let’s Encrypt!

![valid certificate](https://cdn-images-1.medium.com/max/957/1*z8n3PezSDMsyFh2kTBWMHA.png)

---

### Conclusion

Once you have installed cert manager it is really easy to manage your certificates together with _traefik_. You just have to set a couple of parameters in the ingress and the system takes care of everything.

No more excuses for not using a valid certificate!

You can read the article on [Medium](https://medium.com/@albertcolom/easy-steps-to-install-k3s-with-ssl-certificate-by-traefik-cert-manager-and-lets-encrypt-d74947fe7a8){:target="_blank"}
