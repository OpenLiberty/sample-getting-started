#!/bin/bash

echo $PIPELINE_PASSWORD | docker login stg.icr.io -u "$PIPELINE_USERNAME" --password-stdin
docker pull $IMAGE
docker images

docker run -d --name getting-started-sample -p 9080:9080 $IMAGE
docker ps

# Wait for starter planet
maxWait=30
count=0
while [ "$count" != "$maxWait" ] && ! docker logs getting-started-sample | grep -q "CWWKF0011I";
do
    count=$(( $count + 1 ))
    echo "Waiting for CWWKF0011I (Smarter Planet msg) in log. $count / $maxWait seconds."
    sleep 1
done

if [[ "$count" == "$maxWait" ]]; then
    echo "Did not find CWWKF0011I (Smarter Planet msg) in log within $maxWait seconds."
    exit 1;
fi

# Test the endpoints for 200 response code
curl -f -s -I "0.0.0.0:9080" &>/dev/null && echo "OK: Landing page did return 200" || { echo 'FAIL: Sample App landing page did not return 200' ; exit 1; }
curl -f -s "0.0.0.0:9080" | grep -q '<title>Open Liberty - Getting Started Sample</title>' && echo "OK: Sample App landing page contained '<title>Open Liberty - Getting Started Sample</title>'" || { echo 'FAIL: Did not find "<title>Open Liberty - Getting Started Sample</title>" in response' ; exit 1; }
curl -f -s -I "0.0.0.0:9080/system/properties" &>/dev/null && echo "OK: /system/properties did return 200" || { echo 'FAIL: /system/properties did not return 200' ; exit 1; }
curl -f -s -I "0.0.0.0:9080/system/config" &>/dev/null && echo "OK: /system/config did return 200" || { echo 'FAIL: /system/config did not return 200' ; exit 1; }
curl -f -s -I "0.0.0.0:9080/system/runtime" &>/dev/null && echo "OK: /system/runtime did return 200" || { echo 'FAIL: /system/runtime did not return 200' ; exit 1; }
curl -f -s -I "0.0.0.0:9080/health" &>/dev/null && echo "OK: /health did return 200" || { echo 'FAIL: /health did not return 200' ; exit 1; }
curl -f -s "0.0.0.0:9080/metrics" &>/dev/null && echo "OK: /metrics did return 200" || { echo 'FAIL: /metrics did not return 200' ; exit 1; }