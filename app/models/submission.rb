class Submission
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :id, :string
  attribute :state, :string
  attribute :risk, :string
  attribute :current_version, :integer
  attribute :app_store_updated_at, :datetime
  attribute :application_type, :string
  attribute :json_schema_version, :integer
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
  attribute :assigned_user_id, :string
  attribute :events, default: -> { [] }
  attribute :data, default: -> { {} }

  APPLICATION_TYPES = {
    nsm: 'crm7',
    prior_authority: 'crm4',
  }.freeze

  attr_accessor :assigned_user_id

  def namespace
    Submission::APPLICATION_TYPES.invert[application_type].to_s.camelcase.constantize
  end

  def assigned_user
    @assigned_user ||= User.find_by(id: assigned_user_id)
  end

  def to_param
    id
  end

  def rejected?
    state == 'rejected'
  end

  def granted?
    state == 'granted'
  end

  def part_grant?
    state == 'part_grant'
  end

  def provider_updated?
    state == 'provider_updated'
  end

  def sent_back?
    state == 'sent_back'
  end

  def expired?
    state == 'expired'
  end

  class << self
    def load_from_app_store(submission_id)
      data = AppStoreClient.new.get_submission(submission_id)
      rehydrate(data)
    end

    def rehydrate(data)
      accessible = data.with_indifferent_access
      klass = case APPLICATION_TYPES.invert[accessible['application_type']]
              when :nsm then Claim
              when :prior_authority then PriorAuthorityApplication
              else raise "Unknown application type #{accessible['application_type']}"
              end
      klass.new(attributes_from_app_store_data(accessible))
    end

    def attributes_from_app_store_data(data)
      {
        id: data['application_id'],
        state: data['application_state'],
        risk: data['application_risk'],
        current_version: data['version'],
        app_store_updated_at: data['last_updated_at'],
        application_type: data['application_type'],
        json_schema_version: data['json_schema_version'],
        data: data['application'],
        created_at: data['created_at'],
        updated_at: data['updated_at'],
        assigned_user_id: data['assigned_user_id'],
        events: (data['events'] || []).map { Event.rehydrate(_1, data['application_type']) },
      }
    end
  end
end
