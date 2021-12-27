# bazel-docker

[![CI](https://github.com/ZalgoNoise/bazel-docker/actions/workflows/build.yaml/badge.svg)](https://github.com/ZalgoNoise/bazel-docker/actions/workflows/build.yaml)
[![CD](https://github.com/ZalgoNoise/bazel-docker/actions/workflows/push.yaml/badge.svg)](https://github.com/ZalgoNoise/bazel-docker/actions/workflows/push.yaml)
_________



_A Bazel instance deployed in a Docker container, up-to-date with the latest versions._



### Dockerized Bazel Build

[Bazel](https://github.com/bazelbuild/bazel) is a great tool to connecting your codebase together, with reproducible builds. Despite its learning curve, its features make it a great choice over other options such as using Makefiles.

However, Docker deployments of Bazel (by the time of launch of this repo) were very scarce, with either the [official](https://console.cloud.google.com/gcr/images/cloud-marketplace-containers/GLOBAL/google/bazel) and unofficial distributions of a Dockerized Bazel image being very out-of-date or simply not working.

[Bazelisk](https://github.com/bazelbuild/bazelisk) was an option to look into, starting with their template [GitHub Actions](https://github.com/marketplace/actions/setup-bazelisk). But to run locally (and even being able to deploy on incompatible platforms for Bazel), a Docker version would be nice -- and has even been requested several times, in fact.

This image promises to achieve that desire by configuring Bazel in an OpenJDK 11 container. The resulting image is quite large (at 822 MB), but the goal is to build a lighter version of the same. For the moment, this is a working Dockerized Bazel 4.2.2.

### Runtime

Your repo or project (where your `WORKSPACE` file is) should be attached to the container as a volume to its `/src/workspace` directory, the working directory in the container. Optionally, you also have `git` installed in the image.

Your cache should be attached to the container on its `/tmp/build_output` folder, to persist your cache and to take less time and space when using Bazel.

Container runtime follows the indications of the [Bazel Docker Container docs](https://docs.bazel.build/versions/2.2.0/bazel-container.html), but pointing to this container (and without defining already set properties):

```
docker run \
  -e USER="$(id -u)" \
  -u="$(id -u)" \
  -v /src/workspace:/src/workspace \
  -v /tmp/build_output:/tmp/build_output \
  ghcr.io/zalgonoise/bazel:latest \
  build //absl/...
```

The container's entrypoint script already contains a flag to set the cache to `/tmp/build_output`, while taking the remaining arguments as provided when running the container:

```
bazel --output_user_root=/tmp/build_output $@
```

Optionally, you can also run the container interactively, so you can access the bazel command directly:

```
docker run \
  -e USER="$(id -u)" \
  -u="$(id -u)" \
  -v /src/workspace:/src/workspace \
  -v /tmp/build_output:/tmp/build_output \
  --entrypoint=/bin/bash \
  ghcr.io/zalgonoise/bazel:latest 
```

___________

_This is work-in-progress and is not production-ready, yet_
