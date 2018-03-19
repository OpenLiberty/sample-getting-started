![](https://github.com/OpenLiberty/open-liberty/blob/master/logos/logo_horizontal_light_navy.png)

The sample application contains a system microservice to retrieve the system properties and uses MicroProfile Config to simulate the status of the microservice, MicroProfile Health to determine the health of the microservice, and MicroProfile Metrics to provide metrics for the microservice.

## Run Sample application with server running in the background
    mvn clean install

### Include test
    mvn clean install -DskipTests=false

### Stop server
    mvn liberty:stop-server

### Open url's in browser
    http://localhost:9080

