# Introduction for HAProxy with prometheus

Prometheus is now built-in for docker image for version 2.4 from the [community](https://github.com/docker-library/haproxy/tree/master/2.4).

If you wish to bake image on your own, do as example below.
```sh
# note: check your builder supports the platform by run: docker buildx ls
docker build --platform linux/amd64 -t your_username/haproxy:edge
```

Then... mount the configuration file (haproxy.cfg) to following location:
```sh
/usr/local/etc/haproxy/haproxy.cfg
```

For ubuntu... set as...

```sh
/etc/haproxy/haproxy.cfg
```

That's pretty much it. If you need more info, checkout the link down below.

[CLICK](https://blog.dsub.io/haproxy-aka-sni-routing)