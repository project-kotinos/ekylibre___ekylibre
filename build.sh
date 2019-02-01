#!/usr/bin/env bash
set -e

(cd docker/images/ruby-base && docker build -t ekylibre/ruby-base:2.3.8 .)

docker-compose build