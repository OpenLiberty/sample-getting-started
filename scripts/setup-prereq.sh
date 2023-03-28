#!/usr/bin/env bash

set -e -o pipefail

main() {
    ## Define current arch variable
    case "$(uname -p)" in
    "ppc64le")
        readonly arch="ppc64le"
        ;;
    "s390x")
        readonly arch="s390x"
        ;;
    *)
        readonly arch="amd64"
        ;;
    esac

    install_mvn
    install_java
}

install_mvn() {
    DIR="maven"
    # Check if mvn is already installed
    if [ -x "$(command -v mvn)" ] || [ -d "$DIR" ]; then
        echo "Maven is already installed"
    else
        mkdir $DIR
        binary_url="https://dlcdn.apache.org/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.tar.gz"
        curl -o maven.tar.gz $binary_url
        tar xvf maven.tar.gz -C maven --strip-components 1 && rm maven.tar.gz
    fi
}

install_java() {
    DIR="java"
    # Check if java is already installed and its path is setup
    if { [ -x "$(command -v java)" ] && [ ! -z "$JAVA_HOME" ]; } || [ -d "$DIR" ]; then
        echo "Java is already installed"
    else
        mkdir $DIR
        if [[ "$arch" = "s390x" ]]; then
            binary_url="https://api.adoptopenjdk.net/v3/binary/latest/11/ga/linux/s390x/jdk/openj9/normal/adoptopenjdk?project=jdk"
        elif [[ "$arch" = "ppc64le" ]]; then
            binary_url="https://api.adoptopenjdk.net/v3/binary/latest/11/ga/linux/ppc64le/jdk/openj9/normal/adoptopenjdk?project=jdk"
        else
            binary_url="https://api.adoptopenjdk.net/v3/binary/latest/11/ga/linux/x64/jdk/openj9/normal/adoptopenjdk?project=jdk"
        fi

        curl -LJko openjdk.tar.gz $binary_url
        tar xvf openjdk.tar.gz -C java --strip-components 1 && rm openjdk.tar.gz
    fi
}

main "$@"

