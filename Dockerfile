FROM ubuntu:latest

ADD https://github.com/bazelbuild/bazelisk/releases/download/v1.11.0/bazelisk-linux-amd64 \
    /bin/bazel
RUN chmod +x /bin/bazel

RUN apt update -y && apt install -y \
    ca-certificates \
    gcc g++ python3

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN useradd --uid 1005 --home /config --shell  /bin/bash bazel \
    && echo "bazel    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir -p /config/src /tmp/build_output \
    && chown bazel:bazel /tmp/build_output 


WORKDIR /config/src
RUN mkdir -p /tmp/build_output
COPY init /init

# USER bazel
ENTRYPOINT [ "/init" ]
CMD [ "su", "bazel", "-c", "/bin/bazel", "--output_user_root=/tmp/build_output" ]