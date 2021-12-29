# bazel-docker

[![CI](https://github.com/ZalgoNoise/bazel-docker/actions/workflows/build.yaml/badge.svg)](https://github.com/ZalgoNoise/bazel-docker/actions/workflows/build.yaml)
[![CD](https://github.com/ZalgoNoise/bazel-docker/actions/workflows/push.yaml/badge.svg)](https://github.com/ZalgoNoise/bazel-docker/actions/workflows/push.yaml)
_________



_A Bazel instance deployed in a Docker container, up-to-date with the latest versions._



### Dockerized Bazel Build

[Bazel](https://github.com/bazelbuild/bazel) is a great tool to connecting your codebase together, with reproducible builds. Despite its learning curve, its features make it a great choice over other options such as using Makefiles.

However, Docker deployments of Bazel (by the time of launch of this repo) were very scarce, with either the [official](https://console.cloud.google.com/gcr/images/cloud-marketplace-containers/GLOBAL/google/bazel) and unofficial distributions of a Dockerized Bazel image being very out-of-date or simply not working.

[Bazelisk](https://github.com/bazelbuild/bazelisk) was an option to look into, starting with their template [GitHub Actions](https://github.com/marketplace/actions/setup-bazelisk). But to run locally (and even being able to deploy on incompatible platforms for Bazel), a Docker version would be nice -- and has even been requested several times, in fact.

This image promises to achieve that desire by configuring Bazel in a Debian-based container, and installing either Bazelisk or Bazel, allowing the flexibility of Docker alongside Bazel's build system and commodity. This no longer results in a 1GB image size, either.



### Runtime

Your repo or project (where your `WORKSPACE` file is) should be attached to the container as a volume to its `/src/workspace` directory, the working directory in the container. Optionally, you also have `git` installed in the image.

Your cache should be attached to the container on its `/tmp/build_output` folder, to persist your cache and to take less time and space when using Bazel.

Container runtime follows the indications of the [Bazel Docker Container docs](https://docs.bazel.build/versions/2.2.0/bazel-container.html), but pointing to this container (and without defining already set properties):

```
docker run --rm -ti \
  -e PUID=${UID} \
  -e PGID=${GID} \
  -v /src/workspace:/config/src \
  -v ${HOME}/.cache/bazel/_bazel_${USER}:/tmp/build_output \
  ghcr.io/zalgonoise/bazel:latest \
  build //absl/...
```

The container's entrypoint script already contains a flag to set the cache to `/tmp/build_output`, while taking the remaining arguments as provided when running the container:

```
bazel --output_user_root=/tmp/build_output $@
```

Optionally, you can also run the container interactively (as root), add a custom entrypoint flag to get a shell instead of setting up and logging in with your `bazel` user -- which has the same UID / GID as your user:

```
docker run -ti \
  --entrypoint=/bin/bash \
  -v /src/workspace:/config/src \
  -v ${HOME}/.cache/bazel/_bazel_${USER}:/tmp/build_output \
  ghcr.io/zalgonoise/bazel:latest 
```
___________

## Building the container

You can build the container wither `docker` or `docker-compose`, while also being able to specify its Bazel version.

#### Ubuntu container

With `docker`, using the `ubuntu` base image:

```
BAZEL_VERSION=6.0.0-pre.20211215.3
docker build \
  -t bazel:${BAZEL_VERSION} \
  -f Dockerfile_ubuntu \
  --build-arg BAZEL_VERSION=${BAZEL_VERSION} \
  .
```

With `docker-compose`, using the `ubuntu` base image:

```
BAZEL_VERSION=6.0.0-pre.20211215.3
docker-compose build \
  --parallel \
  --build-arg BAZEL_VERSION=${BAZEL_VERSION} \
  bazel-ubuntu
```


#### Debian container

With `docker`, using the `debian` base image:

```
BAZEL_VERSION=6.0.0-pre.20211215.3
docker build \
  -t bazel:${BAZEL_VERSION} \
  -f Dockerfile_debian \
  --build-arg BAZEL_VERSION=${BAZEL_VERSION} \
  .
```

With `docker-compose`, using the `debian` base image:

```
BAZEL_VERSION=6.0.0-pre.20211215.3
docker-compose build \
  --parallel \
  --build-arg BAZEL_VERSION=${BAZEL_VERSION} \
  bazel-debian
```

#### Building all versions 

Speeding up this process, there is a `docker-compose.yaml` file which takes in the versions listed in `.env` and creates a set of tagged images accordingly:

```
BAZEL6=6.0.0-pre.20211215.3
BAZEL5=5.0.0-pre.20211011.2
BAZELL=4.2.2
```

Each image is listed in the compose file, as a service:

```
version: "3.7"
services:

(...)

  bazel-4.2.2:
    build:
      context: .
      dockerfile: ./Dockerfile_ubuntu
      args: 
        BAZEL_VERSION: ${BAZELL}
    image: bazel:${BAZELL}

(...)
```

To build and tag all images and versions, you can run the `docker-compose` command below:

```
docker-compose build --parallel
```

The `versionpush.sh` file is a temporary placeholder to quickly push all tagged images to my repository, from an authorized machine.


___________

_This is work-in-progress and is not production-ready, yet_
