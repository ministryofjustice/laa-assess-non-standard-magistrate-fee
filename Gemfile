# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'aws-sdk-s3', '~> 1.177'
gem 'bootsnap', require: false
gem 'cssbundling-rails', '>= 1.4.1'
gem 'devise', '>= 4.9.4'
gem 'faker'
gem 'govuk-components'
gem 'govuk_design_system_formbuilder'
gem 'govuk_notify_rails', '~> 3.0.0'
gem 'httparty'
gem 'jbuilder'
gem 'jsbundling-rails', '>= 1.3.1'
gem 'laa_crime_forms_common', '~> 0.8.0', github: 'ministryofjustice/laa-crime-forms-common'
gem 'lograge'
gem 'logstasher', '~> 2.1'
gem 'logstash-event'
gem 'oauth2', '~> 2.0'
gem 'omniauth_openid_connect', '0.8.0'
gem 'omniauth-rails_csrf_protection', '>= 1.0.2'
gem 'ostruct'
gem 'pg'
gem 'prometheus_exporter'
gem 'propshaft'
gem 'puma', '~> 6.5'
gem 'pundit'
gem 'rails', '~> 8.0.1'
gem 'redis'
gem 'sidekiq', '~> 7.3'
gem 'sidekiq_alive', '~> 2.4'
gem 'solid_cache'
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
  gem 'erb_lint', '>= 0.6.0', require: false
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
  gem 'rubocop', '>= 1.65.1', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', '>= 2.25.1', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'simplecov_json_formatter', '~> 0.1.4'
  gem 'simplecov-lcov'
  gem 'simplecov-rcov'
  gem 'super_diff'
  gem 'webmock', '~> 3.24'
end
