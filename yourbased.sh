#!/usr/bin/env bash
set -ex


test/ci/before_install
bundle install --jobs=3 --retry=3 --full-index --without development
test/ci/before_script
xvfb-run bundle exec rake test:models test:libs test:controllers DRIVER=webkit
