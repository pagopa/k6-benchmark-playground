#!/bin/bash

set -e

ENV=load

printf "\e[33m|> Installing resources on environment %s \e[0m\n" "$ENV"
cd ./infra || exit 1
./terraform.sh apply "$ENV" -auto-approve
printf "\e[33m|> Done! Please seed your database instance with schema and data.\e[0m\n"
# TODO: run sql seed after apply
#printf "\e[33mApplication installed on environment %s, waiting 10 seconds\e[0m\n" "$ENV"
#sleep 10
#echo "Executing sql seed script"
#echo "Done! Ready to accept requests"
