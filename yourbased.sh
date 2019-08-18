#!/usr/bin/env bash
set -ex

export DEBIAN_FRONTEND=noninteractive
export CI=true
export TRAVIS=true
export CONTINUOUS_INTEGRATION=true
export USER=travis
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export RAILS_ENV=test
export RACK_ENV=test
export MERB_ENV=test
export JRUBY_OPTS="--server -Dcext.enabled=false -Xcompile.invokedynamic=false"

test/ci/before_install
bundle install --full-index --without development
test/ci/before_script
xvfb-run bundle exec rake test:models test:libs test:controllers DRIVER=webkit
