class SearchResults
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  PER_PAGE = 20

  attribute :page, :integer, default: 1
  attribute :sort_by, :string, default: 'last_updated'
  attribute :sort_direction, :string, default: 'descending'

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

  def conduct_search
    AppStoreClient.new.search(search_params).deep_symbolize_keys
  end

  def search_params
    attributes.merge(per_page: PER_PAGE).compact_blank
  end
end
