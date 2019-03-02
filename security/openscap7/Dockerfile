ARG source=registry.access.redhat.com/rhel7
# hadolint ignore=DL3006
FROM $source

RUN yum install -y epel-release \
  && yum install -y openscap-utils scap-security-guide xmlstarlet \
  && yum clean all \
  && rm -rf /var/cache/yum

# We use bash pipes to simplify checking download hashes.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# oscap-docker doesn't run well in a container, so we use docker-companion to
# extract the images, then we can check them with oscap-chroot.
RUN curl -Ls -o /usr/local/bin/docker-companion https://github.com/mudler/docker-companion/releases/download/v0.4.3/docker-companion-0.4.3-linux-amd64 \
  && [ "$(sha256sum < /usr/local/bin/docker-companion | head -c 64)" = "b881c396eb1b89a5e29b42fea34e6eee55ee5403e4021807dc94aeb8961962d7" ]

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/*

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]