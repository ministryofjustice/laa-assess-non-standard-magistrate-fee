# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'activerecord-postgis-adapter'
gem 'aws-sdk-s3', '~> 1.147'
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'devise', '>= 4.9.4'
gem 'govuk-components'
gem 'govuk_design_system_formbuilder'
gem 'govuk_notify_rails', '~> 2.2.0'
gem 'httparty'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'logstasher', '~> 2.1'
gem 'oauth2', '~> 2.0'
gem 'omniauth_openid_connect', '0.7.1'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'propshaft'
gem 'puma', '~> 6.4'
gem 'rails', '~> 7.1.3'
gem 'sidekiq', '~> 7.2', '>= 7.2.4'
gem 'sidekiq_alive', '~> 2.4'
gem 'sidekiq-cron'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
# Pagination
gem 'pagy'
# Exception monitoring
gem 'sentry-rails', '>= 5.17.3'
gem 'sentry-ruby'
gem 'with_advisory_lock'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv-rails'
  gem 'erb_lint', require: false
  gem 'overcommit'
  gem 'pry'
  gem 'rspec-expectations'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails'
end

group :test do
  gem 'axe-core-rspec'
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', '>= 2.24.1', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'simplecov_json_formatter', '~> 0.1.4'
  gem 'simplecov-lcov'
  gem 'simplecov-rcov'
  gem 'super_diff'
  gem 'webmock', '~> 3.23'
end
