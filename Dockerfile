FROM icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi-minimal
ARG VERSION=1.0
ARG REVISION=SNAPSHOT
ARG SKIP_LINPERF=false

LABEL \
  org.opencontainers.image.authors="Alasdair Nottingham" \
  org.opencontainers.image.vendor="IBM" \
  org.opencontainers.image.url="local" \
  org.opencontainers.image.source="https://github.com/OpenLiberty/sample-getting-started" \
  org.opencontainers.image.version="$VERSION" \
  org.opencontainers.image.revision="$REVISION" \
  vendor="Open Liberty" \
  name="system" \
  version="$VERSION-$REVISION" \
  summary="Sample app running on Open Liberty that uses Eclipse MicroProfile" \
  description="This image contains a sample application that displays the Java system properties and demonstrates MicroProfile Config, Health and Metrics."

# Install required packages for running the Liberty MustGather (linperf.sh) script.
USER 0
RUN if [ "$SKIP_LINPERF" != "true" ]; then \
      PKG_MGR=$(command -v dnf || command -v microdnf) && \
      $PKG_MGR install -y procps-ng net-tools ncurses hostname && \
      $PKG_MGR clean all; \
    fi
USER 1001

COPY --chown=1001:0 src/main/liberty/config/ /config/

# Bundle the dev SSO for mpMetrics. You can override at deploy time by mounting a different sso.xml
COPY --chown=1001:0 dev/sso.xml /config/configDropins/overrides/sso.xml

RUN features.sh

COPY --chown=1001:0 target/*.war /config/apps/

RUN configure.sh && rm -rf /output/resources/security/
