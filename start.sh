#!/usr/bin/env bash

# Install Gems
bundle check || bundle install
# Up the server
bundle exec puma -C config/puma.rb