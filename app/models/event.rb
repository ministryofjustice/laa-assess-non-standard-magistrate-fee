class Event < ApplicationRecord
  belongs_to :claim
  belongs_to :primary_user, optional: true, class_name: 'User'

  self.inheritance_column = :event_type

  HISTORY_EVENTS = ['Event::NewVersion'].freeze
  scope :history, -> { where(event_type: HISTORY_EVENTS) }

  # Make these methods private to ensure tehy are created via the various `build` methods`
  class << self
    private :new
    private :create
  end

  def title
    t('title')
  end

  def body
    nil
  end

  private

  def t(key, **)
    I18n.t("#{self.class.to_s.underscore}.#{key}", **)
  end
end
