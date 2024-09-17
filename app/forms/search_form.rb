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
  attribute :submitted_from, :string
  attribute :submitted_to, :string
  attribute :updated_from, :string
  attribute :updated_to, :string
  attribute :status_with_assignment, :string
  attribute :caseworker_id, :string
  attribute :page, :integer, default: 1
  attribute :sort_by, :string, default: 'last_updated'
  attribute :sort_direction, :string, default: 'descending'
  attribute :application_type, :string

  validate :at_least_one_field_set
  validates :application_type, presence: true
  validates :submitted_from, :submitted_to, :updated_from, :updated_to, is_a_date: true

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

    field_set = fields.any? do |field|
      send(field).present?
    end

    return if field_set

    noun = application_type.presence || 'generic'
    errors.add(:base, :nothing_specified, value: I18n.t("shared.submission_noun.#{noun}"))
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
