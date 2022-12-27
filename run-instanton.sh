#!/bin/bash

podman run \
    --rm -p 9080:9080 \
    --cap-add=CHECKPOINT_RESTORE \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_PTRACE \
    -v /proc/sys/kernel/ns_last_pid:/proc/sys/kernel/ns_last_pid \
    dev.local/getting-started-instanton
