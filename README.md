![](https://github.com/OpenLiberty/open-liberty/blob/master/logos/logo_horizontal_light_navy.png)

## Run Sample
    mvn clean install

### Keep server running
    mvn clean install -DskipTests liberty:run-server

### Open url's in browser
    http://localhost:9080/system/properties
    http://localhost:9080/health
    http://localhost:9080/metrics
