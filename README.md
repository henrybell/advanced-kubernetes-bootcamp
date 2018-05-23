# advanced-kubernetes-bootcamp
Cloud Next 2018  -- Advanced Kubernetes Bootcamp code &amp; config

Contains Kubernetes manifests from the [Weaveworks microservices demo](https://github.com/microservices-demo/microservices-demo) application.

## Sock Shop app

The Sock Shop app needs to be published on GCS for it to be automatically
installed by Deployment Manager.

```bash
cd dm-setup
tar czfv sock-shop.tgz deployment-manifests/
gsutil cp -a public-read sock-shop.tgz gs://next-2018-k8s-bootcamp-resources/
```
