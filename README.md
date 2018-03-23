![](https://github.com/OpenLiberty/open-liberty/blob/master/logos/logo_horizontal_light_navy.png)

The sample application contains a system microservice to retrieve the system properties and uses MicroProfile Config to simulate the status of the microservice, MicroProfile Health to determine the health of the microservice, and MicroProfile Metrics to provide metrics for the microservice.

## Run Sample application
    mvn clean install liberty:run-server

### Skip tests
    mvn clean install -DskipTests=true liberty:run-server

### Open url's in browser
    http://localhost:9080

