---
title: "How to create CD with GitHub Actions and Kubernetes in your Golang application"
layout: post
date: 2023-07-10 00:00
image: https://miro.medium.com/v2/resize:fit:4800/format:webp/1*BXSy9C4wxkygjCLJf5m7BA.jpeg
headerImage: false
tag:
- GO
- pipeline
- kubernetes
category: blog
author: albertcolom
description: An example to create pipeline to deploy a simple GO application into k3s cluster with Docker image from scratch.
#externalLink: https://medium.com/@skolom_93361/how-to-create-cd-with-github-actions-and-kubernetes-dbf004dea51
---

![Golang and kubernetes](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*BXSy9C4wxkygjCLJf5m7BA.jpeg)

An example to create pipeline to deploy a simple GO application into k3s cluster with Docker image from scratch.

## Previous requirements:
- [GitHub Account](https://github.com/){:target="_blank"} as PHP framework
- [Kubernetes](https://kubernetes.io/){:target="_blank"} cluster in this example I use a lightweight version of Kubernetes with [K3s](https://k3s.io/){:target="_blank"}

### Simple http application with GO
A simple illustrative example with http server on port 80 with basic handle respond on a main url.

If you already have any application you can go to the next step.

```go
package main

import (
    "fmt"
    "net/http"
    "os"
)

func handler(w http.ResponseWriter, r *http.Request) {
    var name, _ = os.Hostname()
    fmt.Fprintf(w, "<h1>This request was processed by host: %s</h1>\n", name)
}

func main() {
    fmt.Fprintf(os.Stdout, "Web Server started. Listening on 0.0.0.0:80\n")
    http.HandleFunc("/", handler)
    http.ListenAndServe(":80", nil)
}
```

You can run the application to ensure works correctly:

```bash
go run main.com
```

If the application its works then we can prepare docker image to "Dokcerize" the application.

### Build docker image from scrath
Firstly, we create a file named `infrastucture/docker/Dockerfile` to contain all config. We use the `alpine` image as a builder to compile de Go binary and then use image from `scratch` to copy binary with SSL certificates and define de binary as entrypoint.

This way we get a minimal docker image that contain your binary application than ***only around 5 MB!***

```bash
# Use latest Go alpine image as builder
FROM golang:alpine AS build

# Define app as working directory
WORKDIR /app

# Copy all project into docker image
COPY . .

# Compile the Go Application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/bin/demo main.go

# Use minimum image with binary
FROM scratch AS prod

# Copy SSL Certificates from build stage
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

#Copy the application binary from build stage
COPY --from=build /app/bin/demo /app/bin/demo

# Define your binary as entrypoint
ENTRYPOINT ["/app/bin/demo"]
```

And we can make the build of the image:

```bash
docker build -t demo-app:1 . -f ./infrastucture/docker/Dockerfile
```

- `-t`: Name and optionally a tag in the `name:tag` format
- `-f`: Name of the Dockerfile (Default is `PATH/Dockerfile`)

> You can found more options on the oficial documentation: <https://docs.docker.com/engine/reference/commandline/build/#options>

### Connect your K3s cluster with Github
For Github Actions can access to your k3s cluster you need import de kubeconfig into secrets actions.

In k3s you can found the `kubeconfig` on `/etc/rancher/k3s/k3s.yaml`. You kubeconfig will like somehow like this:

```yaml
apiVersion: v1
clusters:
- cluster:
      certificate-authority-data: LS0...
      server: https://your-server.com:6443
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: default
  user:
    client-certificate-data: LS0...
    client-key-data: LS0...
```

Then you go to your project from Github and add the secret named `KUBE_CONFIG` with the k3s.yaml content.

> Project ⮕ Settings ⮕ Secret and Variables ⮕ Actions

![GitHub repository secrets](https://cdn-images-1.medium.com/v2/resize:fit:1600/1*3hSXRSGQt-i85YWnxNxQGA.png)

## Github action for Continuous Delivery (CD)
Finally we come to the long awaited section. We will see how to create a flow with two steps.

Create a file into root of main project: `.github/workflow/cd.yaml where we create a workflow triggered on a push/merge on your principal branch, in this case `main branch.

```yaml
on:
    push:
        branches: [ "main" ]
```

### First step
In the first step build the docker image and publish on the container registry, in this case use the `ghcr` (GitHub Container Registry).

> You can found more information about github packages: <https://docs.github.com/en/packages/learn-github-packages>

```yaml
build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        
      - name: Log in to the Container registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
        
      - name: Build and push
        uses: docker/build-push-action@v3
        with:
          context: .
          platforms: linux/amd64
          file: ./infrastructure/docker/Dockerfile
          push: true
          tags: ghcr.io/${{ github.repository }}/demo-app:${{ github.sha }}
```

### Second step
Publish your docker image from registry to k8s cluster.

First of all need a create a token on github with `read:package` scope and create secret in json format encoded as base64 that you publish on your k8s secrets.

Let's Base64 encode it first:

```bash
echo -n "username:your_token" | base64
#example of output: dXNlcm5hbWU6eW91cl90b2tlbg==
```

> Change `username` for your GitHub username and `your_token` with the previous generated token

Create a json and encode to Base64 again:

```bash
echo -n  '{"auths":{"ghcr.io":{"auth":"dXNlcm5hbWU6eW91cl90b2tlbg=="}}}' | base64
#example of output: eyJhdXRocyI6eyJnaGNyLmlvIjp7ImF1dGgiOiJkWE5sY201aGJXVTZlVzkxY2w5MGIydGxiZz09In19fQ==
```

Create a manifest to deploy your application on kuberntes `deployment`, `service`, `ingress`

```yaml
#infrastructure/kubernetes/demo-app-deployment.yml

apiVersion: apps/v1
kind: Deployment
metadata:
    name: demo-app
spec:
    selector:
        matchLabels:
            app: demo-app
    replicas: 2
    template:
        metadata:
            labels:
            app: demo-app
    spec:
        containers:
            - name: demo-app
              image: ghcr.io/path-to-image/demo-app
              env:
                - name: GIN_MODE
                  value: "release"
              ports:
                - containerPort: 80
              livenessProbe:
                httpGet:
                    path: /
                    port: 80
                initialDelaySeconds: 5
                periodSeconds: 3
              readinessProbe:
                httpGet:
                    path: /
                    port: 80
                initialDelaySeconds: 5
                periodSeconds: 3
```

```yaml
#infrastructure/kubernetes/demo-app-service.yml

apiVersion: v1
kind: Service
metadata:
    name: demo-app
spec:
    ports:
        - port: 80
          protocol: TCP
          targetPort: 80
    type: NodePort
    selector:
        app: demo-app
```

```yaml
#infrastructure/kubernetes/demo-app-ingress.yml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    annotations:
    name: demo-app
spec:
    ingressClassName: nginx
    rules:
        - host: domain.com
          http:
            paths:
                  - path: /
                    pathType: Prefix
                    backend:
                      service:
                          name: demo-app
                          port:
                            number: 80
```

Finally, once we have the manifests and secrets, we can create the last step of the workflow.

```yaml
deploy:
  needs: [build]
  runs-on: ubuntu-latest
  steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Log in to the Container registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
    
      - name: Kubernetes set context
        uses: Azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}
    
      - name: Deploy
        uses: Azure/k8s-deploy@v4.4
        with:
          action: deploy
          strategy: basic
          imagepullsecrets: |
            dockerconfigjson-github-com
          manifests: |
            ./infrastructure/kubernetes/demo-app-deployment.yml
            ./infrastructure/kubernetes/demo-app-service.yml
            ./infrastructure/kubernetes/demo-app-ingress.yml
          images: ghcr.io/${{ github.repository }}/demo-app:${{ github.sha }}
```

And just commit in your project the complete CD workflow config `.github/workflow/cd.yaml`.

```yaml
name: CD

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Log in to the Container registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v3
        with:
          context: .
          platforms: linux/amd64
          file: ./infrastructure/docker/Dockerfile
          push: true
          target: prod
          tags: ghcr.io/${{ github.repository }}/demo-app:${{ github.sha }}

  deploy:
    needs: [build]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Log in to the Container registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Kubernetes set context
        uses: Azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}

      - name: Deploy
        uses: Azure/k8s-deploy@v4.4
        with:
          action: deploy
          strategy: basic
          imagepullsecrets: |
            dockerconfigjson-github-com
          manifests: |
            ./infrastructure/kubernetes/demo-app-deployment.yml
            ./infrastructure/kubernetes/demo-app-service.yml
            ./infrastructure/kubernetes/demo-app-ingress.yml
          images: ghcr.io/${{ github.repository }}/demo-app:${{ github.sha }}
```

Then you can go to `Actions` section in your repository and show all workflows and you can see the summary.

![CD summary workflow](https://cdn-images-1.medium.com/v2/resize:fit:1600/1*bs6Y4PvsGzpN6uONVBzLyA.png)

And that's all just have fun and deploy :-)

You can read the article on [Medium](https://medium.com/@skolom_93361/how-to-create-cd-with-github-actions-and-kubernetes-dbf004dea51){:target="_blank"}
