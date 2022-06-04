 #!/bin/bash -e

 function install_twistlock() {
    DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install uuid-runtime file jq && \
    # Install 'gh'
    #curl -Lo /tmp/gh_1.10.2_linux_amd64.deb https://github.com/cli/cli/releases/download/v1.10.2/gh_1.10.2_linux_amd64.deb && \
    #dpkg -i /tmp/gh_1.10.2_linux_amd64.deb && \
    # Install 'tt' - Twistlock service cli
    wget --no-check-certificate https://w3twistlock.sos.ibm.com/download/tt_latest.zip && \
    unzip -l tt_latest.zip | grep linux_x86_64/tt | awk '{print $4}' | xargs unzip -j tt_latest.zip -d /usr/local/bin
    chmod 755 /usr/local/bin/tt
}

# Install Twistlock
install_twistlock

IBMCLOUD_API_KEY=$(get_env twistlock-ibmcloud-api-key)

echo "List out images for twist-lock scan" 
# loop through listed artifact images and scan each amd64 image
for artifact_image in $(list_artifacts); do
  IMAGE_LOCATION=$(load_artifact $artifact_image name)
  ARCH=$(load_artifact $artifact_image arch)

  echo "image from load_artifact:" $IMAGE_LOCATION 
  echo "arch:" $ARCH
done

echo "perform twist-lock scan" 
# loop through listed artifact images and scan each amd64 image
for artifact_image in $(list_artifacts); do
  IMAGE_LOCATION=$(load_artifact $artifact_image name)
  ARCH=$(load_artifact $artifact_image arch)

  echo "image from load_artifact:" $IMAGE_LOCATION 
  echo "arch:" $ARCH

  if [[ -z ${IMAGE_LOCATION} ]]; then 
    continue
  fi

  if [[ "$ARCH" != "amd64" ]]; then 
    echo $arch " images not supported by twistlock scanning, skipping"
    continue
  fi

  # The "pull" in "pull-and-scan" is a remote action. The image will be pulled and scanned on a remote server, and
  # the results will be dumped to file here.

  # twistlock command
  echo "Scan the image " ${IMAGE_LOCATION}
  tt images pull-and-scan ${IMAGE_LOCATION} --iam-api-key $IBMCLOUD_API_KEY -u "$(get_env twistlock-user-id):$(get_env twistlock-api-key)" -g "websphere" --output-format csv-and-json --json-field-filter include=all

  # save the artifact
  for i in twistlock-scan-results*; do save_result scan-artifact ${i}; done

  # The following scans are here to make it easy to figure out which layer is causing TwistLock to report a vulnerability
  # Scan the base Liberty image 
  echo "Scan the base image icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi"
  tt images pull-and-scan icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi --iam-api-key $IBMCLOUD_API_KEY -u "$(get_env twistlock-user-id):$(get_env twistlock-api-key)" -g "websphere"   

  # save the artifact for the base Liberty image
  for i in twistlock-scan-results*; do save_result scan-artifact ${i}; done

  # Scan the base java image 
  echo "Scan the base image icr.io/appcafe/ibm-semeru-runtimes:open-11-jdk-ubi"
  tt images pull-and-scan icr.io/appcafe/ibm-semeru-runtimes:open-11-jdk-ubi --iam-api-key $IBMCLOUD_API_KEY -u "$(get_env twistlock-user-id):$(get_env twistlock-api-key)" -g "websphere"   

  # save the artifact for the base java image
  for i in twistlock-scan-results*; do save_result scan-artifact ${i}; done

  # Scan the base ubi image 
  echo "Scan the base image registry.access.redhat.com/ubi8/ubi:latest"
  tt images pull-and-scan registry.access.redhat.com/ubi8/ubi:latest --iam-api-key $IBMCLOUD_API_KEY -u "$(get_env twistlock-user-id):$(get_env twistlock-api-key)" -g "websphere"   

  # save the artifact for the base java image
  for i in twistlock-scan-results*; do save_result scan-artifact ${i}; done
done