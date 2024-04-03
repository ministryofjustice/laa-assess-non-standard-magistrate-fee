class Event < ApplicationRecord
  belongs_to :submission
  belongs_to :primary_user, optional: true, class_name: 'User'

  self.inheritance_column = :event_type

  PUBLIC_EVENTS = ['Event::Decision', 'PriorAuthority::Event::SendBack'].freeze
  NAMESPACED_EVENT_TYPES = %w[send_back draft_send_back].freeze
  HISTORY_EVENTS = [
    'Event::Assignment',
    'Event::ChangeRisk',
    'Event::Decision',
    'Event::DraftDecision',
    'Event::Expiry',
    'Event::NewVersion',
    'Event::Note',
    'Event::ProviderUpdated',
    'Event::Unassignment',
    'Nsm::Event::SendBack',
    'PriorAuthority::Event::DraftSendBack',
    'PriorAuthority::Event::SendBack',
  ].freeze
  scope :history, -> { where(event_type: HISTORY_EVENTS).order(created_at: :desc) }

  # simplifies the rehydrate process
  attribute :public

  # Make these methods private to ensure they are created via the various `build` methods`
  class << self
    protected :new
    private :create

    def rehydrate!(params, application_type)
      create_dummy_user_if_non_production(params) unless HostEnv.production?

      event_type = params.delete('event_type')
      klass = if event_type.in?(NAMESPACED_EVENT_TYPES)
                top_level = Submission::APPLICATION_TYPES.invert[application_type]
                "#{top_level.to_s.classify}::Event::#{event_type.classify}".constantize
              else
                "Event::#{event_type.classify}".constantize
              end
      klass.new(params).save!
    end

    def latest_decision
      where(event_type: 'Event::Decision').order(:created_at).last
    end

    def latest_provider_update
      where(event_type: 'Event::ProviderUpdated').order(:created_at).last
    end

    private

    def create_dummy_user_if_non_production(params)
      return if params['primary_user_id'].blank?

      User.find_or_initialize_by(id: params['primary_user_id']) do |user|
        user.update!(
          first_name: params['primary_user_id'].split('-').first,
          role: User::CASEWORKER,
          email: "#{params['primary_user_id']}@fake.com",
          last_name: 'branchbuilder',
          auth_oid: params['primary_user_id'],
          auth_subject_id: params['primary_user_id'],
          last_auth_at: Time.zone.now,
          first_auth_at: Time.zone.now
        )
      end
    end
  end

  def title
    t('title', **title_options)
  end

  def body
    details['comment']
  end

  def as_json(*)
    super
      .except('submission_id')
      .merge(
        public: PUBLIC_EVENTS.include?(event_type),
        event_type: event_type.demodulize.underscore
      )
  end

  private

  def title_options
    {}
  end

  def t(key, **)
    I18n.t("#{self.class.to_s.underscore}.#{key}", **)
  end
end
