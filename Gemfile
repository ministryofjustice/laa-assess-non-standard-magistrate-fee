# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'bootsnap', require: false
gem 'dartsass-rails', '~> 0.5.0'
gem 'devise'
gem 'govuk-components'
gem 'govuk_design_system_formbuilder'
gem 'httparty'
gem 'importmap-rails'
gem 'jbuilder'
gem 'omniauth_openid_connect', '0.7.1'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'puma', '~> 6.4'
gem 'rails', '~> 7.1.1'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
# Pagination
gem 'pagy'
# Exception monitoring
gem 'sentry-rails'
gem 'sentry-ruby'

group :development, :test do
  gem 'debug'
  gem 'dotenv-rails'
  gem 'erb_lint', require: false
  gem 'pry'
  gem 'rspec-expectations'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-html-matchers'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov'
  gem 'simplecov_json_formatter', '~> 0.1.4'
  gem 'simplecov-lcov'
  gem 'simplecov-rcov'
  gem 'super_diff'
end
