module Nsm
  module V1
    class Document < BaseViewModel
      attribute :file_name, :string
      attribute :file_path, :string
      attribute :file_size, :integer
      attribute :file_type, :string
      attribute :document_type, :string
    end
  end
end
