#!/bin/bash

set -e

ENV=load

printf "\e[33m|> Destroying resources from environment %s (will lose data)\e[0m\n" "$ENV"
sleep 5
cd ./infra || exit 1
./terraform.sh destroy "$ENV" -auto-approve
printf "\e[33m|> Done!\e[0m\n"
