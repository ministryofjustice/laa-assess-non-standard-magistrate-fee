# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LaaAssessNonStandardMagistrateFee
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    #
    # NOTE: govuk_design_system_formbuilder monkey patch in lib folder is not
    # autoloaded because it the gem itself uses a non-standard/convention filename
    # to classname pattern.
    config.autoload_lib(ignore: %w(assets tasks govuk_design_system_formbuilder))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    # The maximum time since a users was last authenticated on DOM1 before

    # they are automatically signed out.
    config.x.auth.reauthenticate_in = 12.hours

    # The maximum period of inactivity before a user is
    # automatically signed out.
    config.x.auth.timeout_in = 30.minutes

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = :mailers

    config.exceptions_app = ->(env) {
      ErrorsController.action(:show).call(env)
    }

    config.active_model.i18n_customize_full_message = true

    config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets")

    config.x.contact.support_email = 'CRM457@digital.justice.gov.uk'
    config.x.application.name = 'Assess a crime form'
    config.x.analytics.cookies_consent_name = 'cookies_preferences_set'
    config.x.analytics.cookies_consent_expiration = 1.year
    config.x.analytics.analytics_consent_name = 'analytics_preferences_set'
    config.x.analytics.analytics_consent_expiration = 1.year
    config.x.rfi.resubmission_window = 14.days

    config.x.nsm.provider_feedback_url = 'https://eu.surveymonkey.com/r/PDDG6YB'
    config.x.prior_authority.provider_feedback_url = 'https://eu.surveymonkey.com/r/authprior'

    #time to wait for requests to be made to app store for db consistency
    config.x.application.app_store_wait = ENV.fetch('APP_STORE_WAIT_SECS',0).to_i
  end
end
