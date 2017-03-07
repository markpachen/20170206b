#!/bin/bash

echo "Trigger AQA scan and get the reference number of that scan"
refId=$(curl -s "http://172.25.159.27:9090/aqa-rest/ci/scan?token=DEMO-1234567890&pid=ReadingApp&scan=ReadingPhase1&engine=aqa,fortify&fortify=true" | python -c 'import sys, json; print json.load(sys.stdin)["result"]')

echo "Get the status of the scan with specific reference number refId"
status=$(curl -s "http://172.25.159.27:9090/aqa-rest/ci/status?token=DEMO-1234567890&rid=$refId" | python -c 'import sys, json; print json.load(sys.stdin)["result"]')

echo "Check the finish key done of the scan status"
while [ "$status" != "done" ]
	do
		sleep 30
		status=$(curl -s "http://172.25.159.27:9090/aqa-rest/ci/status?token=DEMO-1234567890&rid=$refId" | python -c 'import sys, json; print json.load(sys.stdin)["result"]')
done

echo "Parse the scan score"
quaScore=$(curl -s "http://172.25.159.27:9090/aqa-rest/ci/result?token=DEMO-1234567890&rid=$refId" | python -c 'import sys, json; print json.load(sys.stdin)["result"]["quaScore"]')

# expr return 0 if the quaScore greater than 4.00 o.w. return 1
echo "AQA scan score is " $quaScore

exitCode=$(expr $quaScore '<' 4.000)
echo "AQAscan.sh return: " $exitCode

exit $(expr $quaScore '<' 4.000)
