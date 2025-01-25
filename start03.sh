#!/bin/bash
docker compose exec app bin/rails g scaffold reviews exhibition:string --skip-jbuilder --skip-helper --skip-test-framework
docker compose exec app rails db:migrate

