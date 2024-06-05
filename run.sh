#!/bin/sh
cd /usr/src/app

bundle exec bin/rails db:prepare db:seed && bundle exec pumactl -F config/puma.rb start
