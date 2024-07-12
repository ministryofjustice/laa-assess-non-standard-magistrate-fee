# frozen_string_literal: true

module ApplicationHelper
  LONDON_TIMEZONE = 'Europe/London'

  def current_application
    raise 'implement this action, in subclasses'
  end

  def title(page_title)
    content_for(
      :page_title, [page_title.presence, service_name, 'GOV.UK'].compact.join(' - ')
    )
  end

  # In local/test we raise an exception, so we are aware a title has not been set
  def fallback_title
    exception = StandardError.new("page title missing: #{controller_name}##{action_name}")
    raise exception if Rails.application.config.consider_all_requests_local

    title ''
  end

  def service_name
    t('service.name')
  end

  def app_environment
    "app-environment-#{ENV.fetch('ENV', 'local')}"
  end

  def format_period(period, style: :short)
    return period if period.blank?
    return "#{period / 60}:#{format('%02d', (period % 60))}" if style == :minimal

    t("helpers.time_period.hours.#{style}", count: period / 60) +
      t("helpers.time_period.minutes.#{style}", count: period % 60)
  end

  def format_in_zone(time_or_string, format: Date::DATE_FORMATS[:stamp])
    return unless time_or_string

    time_or_string = DateTime.parse(time_or_string) if time_or_string.is_a?(String)
    l(time_or_string.in_time_zone(LONDON_TIMEZONE), format:)
  end

  def multiline_text(string)
    sanitize(string.gsub("\n", '<br>'), tags: %w[br])
  end

  def govuk_error_summary(form_object)
    return if form_object.try(:errors).blank?

    # Prepend to page title so screen readers read it out as soon as possible
    content_for(:page_title, flush: true) do
      content_for(:page_title).insert(0, t('errors.page_title_prefix'))
    end

    fields_for(form_object, form_object) do |f|
      f.govuk_error_summary t('errors.error_summary.heading')
    end
  end

  def gbp_field_value(value)
    return value if value.is_a?(String)

    number_with_precision(value, precision: 2, delimiter: ',')
  end
end
