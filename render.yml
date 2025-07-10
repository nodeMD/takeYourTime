services:
  - type: web
    name: takeyourtime
    env: ruby
    buildCommand: "./build.sh"
    startCommand: "bundle exec puma -C config/puma.rb"
    envVars:
      - key: RACK_ENV
        value: production
      - key: PORT
        value: 10000
      - key: RAILS_SERVE_STATIC_FILES
        value: enabled