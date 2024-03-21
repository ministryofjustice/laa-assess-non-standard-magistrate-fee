class Event < ApplicationRecord
  belongs_to :submission
  belongs_to :primary_user, optional: true, class_name: 'User'

  self.inheritance_column = :event_type

  PUBLIC_EVENTS = ['Event::Decision', 'Event::SendBack'].freeze
  HISTORY_EVENTS = [
    'Event::Assignment',
    'Event::Decision',
    'Event::DraftDecision',
    'Event::ChangeRisk',
    'Event::NewVersion',
    'Event::Note',
    'Event::SendBack',
    'Event::DraftSendBack',
    'Event::Unassignment',
  ].freeze
  scope :history, -> { where(event_type: HISTORY_EVENTS).order(created_at: :desc) }

  # simplifies the rehydrate process
  attribute :public

  # Make these methods private to ensure they are created via the various `build` methods`
  class << self
    protected :new
    private :create

    def rehydrate!(params)
      create_dummy_user_if_non_production(params) unless HostEnv.production?

      new(params).save!
    end

    def latest_decision
      order(created_at: :desc).find_by(event_type: 'Event::Decision')
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
      .slice!('id', 'submission_id')
      .merge(
        public: PUBLIC_EVENTS.include?(event_type),
        event_type: event_type
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
