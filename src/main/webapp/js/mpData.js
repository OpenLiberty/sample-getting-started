function displayMetrics() {
    getSystemMetrics();
}

function getSystemMetrics() {
    var url = "https://localhost:9443/metrics";
    var req = new XMLHttpRequest();

    var metricToDisplay = {};
    metricToDisplay["application:get_properties"] = "Request Count";
    metricToDisplay["application:io_openliberty_sample_system_system_resource_get_properties_time_min_seconds"] = "Min Request Time (ms)";
    metricToDisplay["application:io_openliberty_sample_system_system_resource_get_properties_time_mean_seconds"] = "Mean Request Time (ms)";
    metricToDisplay["application:io_openliberty_sample_system_system_resource_get_properties_time_max_seconds"] = "Max Request Time (ms)";
    metricToDisplay["base:cpu_process_cpu_load_percent"] = "System CPU Usage (%)";
    metricToDisplay["base:memory_used_heap_bytes"] = "System Heap Usage (MB)";

    var metricToMatch = "^(";
    for (var metricKey in metricToDisplay) {
        metricToMatch += metricKey + "|"
    }
    // remove the last |
    metricToMatch = metricToMatch.substring(0, metricToMatch.length-1);
    metricToMatch += ")\\s*(\\S*)$"

    req.onreadystatechange = function() {
        if (req.readyState != 4) return; // Not there yet
        if (req.status != 200) {
            document.getElementById("metricsText").innerHTML = req.statusText;
            return;
        }

        var resp = req.responseText;
        var regexpToMatch = new RegExp(metricToMatch, "gm");
        var matchMetrics = resp.match(regexpToMatch);

        var keyValPairs = {};
        for (var metricKey in metricToDisplay) {
            matchMetrics.forEach(function(line) {
                var keyToMatch = metricKey + " (.*)";
                var keyVal = line.match(new RegExp(keyToMatch));
                if (keyVal) {
                    var val = keyVal[1];
                    if (metricKey.indexOf("application:io_openliberty_sample_system_system_resource_get_properties_time") === 0) {
                        val = val * 1000;
                    } else if (metricKey.indexOf("base:memory_used_heap_bytes") === 0) {
                        val = val / 1000000;
                    }
                    keyValPairs[metricToDisplay[metricKey]] = val;
                }
            })
        }

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
    var propToDisplay = ["java.vendor", "java.version", "user.name", "os.name", "wlp.install.dir", "wlp.server.name" ];
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
        for (var i = 0; i < propToDisplay.length; i++) {
            var key = propToDisplay[i]; 
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

function displayConfigProperties() {
    getConfigPropertiesRequest();
}

function getConfigPropertiesRequest() {
    var url = "https://localhost:9443/sampleApp/config";
    var req = new XMLHttpRequest();

    var configToDisplay = {};
    configToDisplay["io_openliberty_sample_system_inMaintenance"] = "System In Maintenance";
    configToDisplay["io_openliberty_sample_testConfigOverwrite"] = "Test Config Overwrite";
    configToDisplay["io_openliberty_sample_port_number"] = "Port Number";
    // Create the callback:
    req.onreadystatechange = function () {
        if (req.readyState != 4) return; // Not there yet
        if (req.status != 200) {
            return;
        }

        // Request successful, read the response
        var resp = JSON.parse(req.responseText);
        var configProps = resp["ConfigProperties"];
        var table = document.getElementById("configTableBody");
        for (key in configProps) {
            var row = document.createElement("tr");
            var keyData = document.createElement("td");
            keyData.innerText = configToDisplay[key];
            var valueData = document.createElement("td");
            valueData.innerText = configProps[key];
            row.appendChild(keyData);
            row.appendChild(valueData);
            table.appendChild(row);
        }    
        
    }
    req.open("GET", url, true);
    req.send();
}
