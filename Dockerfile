FROM openjdk:11-slim
# FROM openjdk:19-bullseye

ARG BAZEL_VERSION=4.2.2

ENV UID=1000
ENV GID=1000

RUN apt update -y \
    && apt install -y \
    curl \
    zip \
    unzip \
    g++ \
    zlib1g-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --output bazel.deb.sha256 \
    "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel_${BAZEL_VERSION}-linux-x86_64.deb.sha256"

RUN curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --remote-name \
    "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel_${BAZEL_VERSION}-linux-x86_64.deb" \
    && cat bazel.deb.sha256 | sha256sum -c - 

RUN dpkg -i "bazel_${BAZEL_VERSION}-linux-x86_64.deb" \
    && rm "bazel_${BAZEL_VERSION}-linux-x86_64.deb" bazel.deb.sha256

WORKDIR /src/workspace
RUN mkdir -p /tmp/build_output
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]