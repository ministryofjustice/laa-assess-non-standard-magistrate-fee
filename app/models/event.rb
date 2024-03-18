class Event < ApplicationRecord
  belongs_to :submission
  belongs_to :primary_user, optional: true, class_name: 'User'

  self.inheritance_column = :event_type

  PUBLIC_EVENTS = ['Event::Decision'].freeze
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

  # Make these methods private to ensure tehy are created via the various `build` methods`
  class << self
    protected :new
    private :create

    def rehydrate!(params)
      new(params).save!
    end

    def latest_decision
      order(created_at: :desc).find_by(event_type: 'Event::Decision')
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
