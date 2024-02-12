class Submission
  include ActiveModel::Model
  include ActiveModel::Attributes

  APPLICATION_TYPES = {
    nsm: 'crm7',
    prior_authority: 'crm4',
  }.freeze

  attribute :events, array: true, default: -> { [] }
  attribute :id, :string
  attribute :state, :string
  attribute :risk, :string
  attribute :current_version, :integer
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
  attribute :application_type, :string
  attribute :json_schema_version, :integer
  attribute :data
  attribute :assigned_user

  def to_param
    id
  end

  def namespace
    Submission::APPLICATION_TYPES.invert[application_type].to_s.camelcase.constantize
  end
end
