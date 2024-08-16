class SearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  Option = Struct.new(:value, :label)
  APPLICATION_TYPES = [
    Option.new('crm4', I18n.t('shared.application_type.crm4')),
    Option.new('crm7', I18n.t('shared.application_type.crm7'))
  ].freeze

  PER_PAGE = 20

  attribute :query, :string
  attribute :submitted_from, :date
  attribute :submitted_to, :date
  attribute :updated_from, :date
  attribute :updated_to, :date
  attribute :status_with_assignment, :string
  attribute :caseworker_id, :string
  attribute :page, :integer, default: 1
  attribute :sort_by, :string, default: 'last_updated'
  attribute :sort_direction, :string, default: 'descending'
  attribute :application_type, :string
  attribute :explicit_application_type, :boolean, default: false

  validate :at_least_one_field_set
  validate :application_type_check

  def results
    @search_response[:raw_data].map { SearchResult.new(_1) }
  end

  def pagy
    Pagy.new(count: @search_response.dig(:metadata, :total_results),
             limit: PER_PAGE,
             page: page,
             fragment: '#search-results')
  end

  def execute
    @search_response = conduct_search
  end

  def executed?
    @search_response.present?
  end

  def caseworkers
    [show_all] + User.order(:last_name, :first_name).map { Option.new(_1.id, _1.display_name) }
  end

  def statuses
    [show_all] + %i[
      not_assigned
      in_progress
      provider_updated
      sent_back
      granted
      auto_grant
      part_grant
      rejected
      expired
    ].map { Option.new(_1, I18n.t("search.statuses.#{_1}")) }
  end

  def application_types
    self.class::APPLICATION_TYPES
  end

  private

  def at_least_one_field_set
    fields = [:query, :submitted_from,
              :submitted_to, :updated_from,
              :updated_to, :status_with_assignment,
              :caseworker_id]

    fields.append(:application_type) if explicit_application_type

    field_set = fields.any? do |field|
      send(field).present?
    end

    errors.add(:base, :nothing_specified, value: I18n.t("shared.submission_noun.#{application_type}")) unless field_set
  end

  def application_type_check
    errors.add(:application_type, :nothing_specified) if explicit_application_type && send(:application_type).blank?
  end

  def search_params
    attributes.merge(per_page: PER_PAGE).compact_blank
  end

  def conduct_search
    AppStoreClient.new.search(search_params).deep_symbolize_keys
  rescue StandardError => e
    Sentry.capture_exception(e)
    errors.add(:base, :search_error)
    nil
  end

  def show_all
    @show_all ||= Option.new('', I18n.t('search.show_all'))
  end
end
