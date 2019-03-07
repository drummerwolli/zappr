#!/bin/bash

echo "Setting up database ..."
docker exec -it zappr-postgres sh -c "exec psql -c 'create database zappr;' -U postgres"
docker exec -it zappr-postgres sh -c "exec psql -c 'create schema zappr_data;' -U postgres zappr"
docker exec -it zappr-postgres sh -c "exec psql -c 'create schema zappr_meta;' -U postgres zappr"

echo "Done setting up database ..."
