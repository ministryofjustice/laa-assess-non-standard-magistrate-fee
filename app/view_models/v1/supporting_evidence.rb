module V1
  class SupportingEvidence < BaseViewModel
    attribute :id
    attribute :file_name
    attribute :file_type
    attribute :file_path
    attribute :created_at, :date
    attribute :updated_at, :date
    attribute :download_url
  end
end
