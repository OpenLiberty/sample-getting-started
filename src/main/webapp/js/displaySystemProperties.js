
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
                    console.log(key + ": " + val);
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
