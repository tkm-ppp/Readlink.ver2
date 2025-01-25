#!/bin/bash
docker compose up postgres -d
docker compose run --rm app rails db:create
docker compose stop postgres
docker compose up

