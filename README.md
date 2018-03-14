![](https://github.com/OpenLiberty/open-liberty/blob/master/logos/logo_horizontal_light_navy.png)

## Run Sample with server running in the background
    mvn clean install

### Include test
    mvn clean install -DskipTests=false

### Stop server
    mvn clean install libarty:stop-server

### Open url's in browser
    https://localhost:9443/systemApp

