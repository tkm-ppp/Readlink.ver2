#!/bin/bash
chmod +x add_db_config.sh
docker compose build
docker compose run --rm app gem install rails -v 7.2.2
docker compose run --rm app rails _7.2.2_ new . -d postgresql -j esbuild
