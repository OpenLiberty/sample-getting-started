![image](https://github.com/OpenLiberty/open-liberty/raw/release/logos/logo_horizontal_light_navy.png)

# Open Liberty Getting Started sample

## Overview
The sample application provides a simple example of how to get started with Open Liberty. It provides a REST API that retrieves the system properties in the JVM and a web based UI for viewing them. It also uses MicroProfile Config, MicroProfile Health and MicroProfile Metrics to demonstrate how to use these specifications in an application that maybe deployed to kubernetes.

## Project structure

- `src/main/java` - the Java code for the Project
  - `io/openliberty/sample`
    - `config`
      - `ConfigResource.java` - A REST Resource that exposes MicroProfile Config via a /rest/config GET request
      - `CustomConfigSource.java` - A MicroProfile Config  ConfigSource that reads a json file.
    - `system`
      - `SystemConfig.java` - A CDI bean that will report if the
      application is in maintenance. This supports the config variable changing dynamically via an update to a json file.
      - `SystemHealth.java` - A MicroProfile Health check that  reports DOWN if the application is in maintenance and UP otherwise.
      - `SystemResource.java` - A REST Resource that exposes the System properties via a /rest/properties GET request. Calls to this GET method have MicroProfile Timer and Count metrics applied.
      - `SystemRuntime.java` - A REST Resource that exposes the version of the Open Liberty runtime via a /rest/runtime GET request.
    - `SystemApplication.java` - The Jakarta RESTful Web services Application class
  - `liberty/config/server.xml` - The server configuration for liberty
  - `META-INF` - Contains the metadata files for MicroProfile config including how to load CustomConfigSource.Java
  - `webapp` - Contains the Web UI for the application.
- `resources/CustomConfigSource.json` - Contains the data that is read by the MicroProfile Config ConfigSource.
- `Dockerfile` - The docker file for building the sample
- `pom.xml` - The maven pom file

## Build and Run the Sample locally

Clone the project

```
git clone https://github.com/OpenLiberty/sample-getting-started.git
```

then build and run it using Liberty dev mode:

```
mvnw liberty:dev
```

if you just want to build it run:

```
mvnw package
```

## Run the Sample in a container

To run the sample using docker run:

```
docker run -p 9080:9080 icr.io/appcafe/open-liberty/samples/getting-started
```

To run the sample using podman run:

```
podman run -p 9080:9080 icr.io/appcafe/open-liberty/samples/getting-started
```


### Access the application
Open a browser to http://localhost:9080

![image](https://user-images.githubusercontent.com/3076261/117993383-4f34c980-b305-11eb-94b5-fa7319bc2850.png)
