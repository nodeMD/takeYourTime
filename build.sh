#!/usr/bin/env bash
# Exit on error
set -o errexit

# Install dependencies
bundle install

# Run migrations if needed
bundle exec rake db:migrate