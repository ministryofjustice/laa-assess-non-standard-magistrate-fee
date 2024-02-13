class Event
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.hydrate(json)
    klass = "Event::#{json['event_type'].camelize}".constantize
    klass.new(json)
  end

  attribute :primary_user_id, :string
  attribute :submission_version, :integer
  attribute :event_type, :string
  attribute :secondary_user_id, :string
  attribute :linked_type, :string
  attribute :linked_id, :string
  attribute :details
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
  attribute :public, :boolean

  def primary_user
    @primary_user ||= User.find(primary_user_id) if primary_user_id
  end

  def secondary_user
    @secondary_user ||= User.find(secondary_user_id) if secondary_user_id
  end

  def historical?
    true
  end

  def title
    t('title', **title_options)
  end

  def body
    return nil unless details

    details['comment']
  end

  private

  def title_options
    {}
  end

  def t(key, **)
    I18n.t("#{self.class.to_s.underscore}.#{key}", **)
  end
end
