FROM icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi
ARG VERSION=1.0
ARG REVISION=SNAPSHOT

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

COPY --chown=1001:0 src/main/liberty/config/ /config/
COPY --chown=1001:0 resources/ /output/resources/

RUN features.sh

COPY --chown=1001:0 target/*.war /config/apps/

RUN configure.sh && rm -rf /output/resources/security/
