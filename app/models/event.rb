class Event < ApplicationRecord
  belongs_to :claim
  belongs_to :primary_user, optional: true, class_name: 'User'

  self.inheritance_column = :event_type

  PUBLIC_EVENTS = ['Event::Decision'].freeze
  HISTORY_EVENTS = ['Event::NewVersion', 'Event::Decision', 'Event::ChangeRisk'].freeze
  scope :history, -> { where(event_type: HISTORY_EVENTS) }

  # simplifies the rehydrate process
  attribute :public

  # Make these methods private to ensure tehy are created via the various `build` methods`
  class << self
    private :new
    private :create

    def rehydrate!(params)
      new(params).save!
    end
  end

  def title
    t('title', **title_options)
  end

  def body
    nil
  end

  def as_json(*)
    super
      .slice!('id', 'claim_id')
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
