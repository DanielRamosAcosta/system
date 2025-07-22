edit a secret:

```
agenix -e nginx.env.age
```

## Charts values:

* [Kubernetes Dashboard](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard)
* [Bitnami PostgreSQL](https://artifacthub.io/packages/helm/bitnami/postgresql)


## TODO

* redirect all http traffic to https in traefik
* make nextcloud aware that's behind tls
* fix OpenID connect, redirect URI is https.
* integrate: https://github.com/favonia/cloudflare-ddns
* even better: https://github.com/kubernetes-sigs/external-dns
