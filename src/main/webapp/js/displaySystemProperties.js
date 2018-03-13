function displayMetrics() {
    getSystemMetrics();
}

function getSystemMetrics() {
    var url = "https://localhost:9443/metrics";
    var req = new XMLHttpRequest();

    req.onreadystatechange = function() {
        if (req.readyState != 4) return; // Not there yet
        if (req.status != 200) {
            document.getElementById("metricsText").innerHTML = req.statusText;
            return;
        }

        var resp = req.responseText;

        var regEx = /^application:(.*) ([0-9.]*)$/gm;
        var keyValRegEx = /application:(.*) ([0-9.]*)/;  // Use this for two matching groups: prop name and value
        
        var keyValPairs = {};

        var matches = resp.match(regEx);
        matches.forEach(function(line){
            var keyVal = line.match(keyValRegEx); // key is [1], value is [2]
            keyValPairs[keyVal[1]] = keyVal[2];
        });

        var table = document.getElementById("metricsTableBody");
        for (key in keyValPairs) {
            var row = document.createElement("tr");
            var keyData = document.createElement("td");
            keyData.innerText = key;
            var valueData = document.createElement("td");
            valueData.innerText = keyValPairs[key];
            row.appendChild(keyData);
            row.appendChild(valueData);
            table.appendChild(row);
        }    
    };
    
    req.open("GET", url, true, "confAdmin", "microprofile");
    req.send();
}

function displaySystemProperties() {
    //console.log("table", document.getElementById("systemPropertiesTable"));
    //document.getElementById('systemPropertiesTable').innerHTML = 'system properties table here';
    getSystemPropertiesRequest();
}

function getSystemPropertiesRequest() {
    var url = "https://localhost:9443/sampleApp/system/properties";
    var req = new XMLHttpRequest()
    // Create the callback:
    req.onreadystatechange = function () {
        if (req.readyState != 4) return; // Not there yet
        if (req.status != 200) {
            document.getElementById("systemPropertiesTable").innerHTML = "Status: " + req.statusText;
            return;
        }
        var propTable = document.getElementById("systemPropertiesTable");
        // Request successful, read the response
        var resp = JSON.parse(req.responseText);
        for (var key in resp) {
            if (resp.hasOwnProperty(key)) {
                var val = resp[key];
                var keyElem = document.createElement('div');
                keyElem.innerHTML = key;
                var valElem = document.createElement('div');
                valElem.innerHTML = val;
                propTable.appendChild(keyElem);
                propTable.appendChild(valElem);
            }
        }
        //document.getElementById("systemPropertiesTable").innerHTML = resp;
    }
    req.open("GET", url, true);
    req.send();
}

function displayHealth() {
    getHealth();
}

function getHealth() {
    var url = "https://localhost:9443/health";
    var req = new XMLHttpRequest();

    var healthBox = document.getElementById("healthBox");
    var serviceName = document.getElementById("serviceName");
    var healthStatus = document.getElementById("serviceStatus");

    req.onreadystatechange = function () {
        if (req.readyState != 4) return; // Not there yet

        // Request successful, read the response
        if (req.responseText) {
            var resp = JSON.parse(req.responseText);
            var service = resp.checks[0]; //TODO: use for loop for multiple services

            resp.checks.forEach(function (service) {
                serviceName.innerText = service.name;
                healthStatus.innerText = service.state;

                if (service.state === "UP") {
                    healthBox.style.backgroundColor = "lime";
                } else {
                    healthBox.style.backgroundColor = "red";
                }
            });
        }
    }
    req.open("GET", url, true);
    req.send();
}
