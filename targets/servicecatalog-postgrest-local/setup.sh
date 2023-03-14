#!/bin/bash

set -e

source .env

docker-compose --env-file .env up -d
echo "Application started, waiting 10 seconds"
sleep 10
echo "Executing sql seed script"
docker-compose exec db psql -U $PG_USER -d $PG_DB -f /var/scripts/db.sql
echo "Done! Ready to accept requests"
