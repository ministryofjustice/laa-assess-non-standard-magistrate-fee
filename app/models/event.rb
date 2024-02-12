class Event
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.hydrate(json)
    klass = json['event_type'].contantize
    klass.new(json)
  end

  attribute :primary_user_id, :string
  attribute :submission_version, :integer
  attribute :event_type, :string
  attribute :secondary_user, :string
  attribute :linked_type, :string
  attribute :linked_id, :string
  attribute :details
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  def primary_user
    @primary_user ||= User.find(primary_user_id)
  end

  def secondary_user
    @secondary_user ||= User.find(secondary_user_id)
  end

  def historical?
    event_type.in?(HISTORY_EVENTS)
  end

  PUBLIC_EVENTS = ['Event::Decision'].freeze
  HISTORY_EVENTS = [
    'Event::Assignment',
    'Event::Decision',
    'Event::ChangeRisk',
    'Event::NewVersion',
    'Event::Note',
    'Event::SendBack',
    'Event::Unassignment',
  ].freeze

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
