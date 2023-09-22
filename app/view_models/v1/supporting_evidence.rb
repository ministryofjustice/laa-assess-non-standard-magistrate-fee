module V1
  class SupportingEvidence < BaseViewModel
    attribute :file_name
    attribute :file_url
    attribute :created_at, :date
    attribute :updated_at, :date
  end
end
