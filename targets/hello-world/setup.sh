#!/bin/bash

SELFFF=$(SELFFF=$(dirname "$0") && bash -c "cd \"$SELFFF\" && pwd")
echo $SELFFF
docker run --name hello-world-server --rm -v "$SELFFF"/targets/hello-world:/usr/src/app -w /usr/src/app -p 8080:8080 -d node:18-alpine node server.js
sleep 2
