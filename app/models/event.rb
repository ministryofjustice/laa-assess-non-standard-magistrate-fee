class Event
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :id, :string, default: -> { SecureRandom.uuid }
  attribute :primary_user_id, :string
  attribute :secondary_user_id, :string
  attribute :linked_type, :string
  attribute :linked_id, :string
  attribute :details, default: -> { {} }
  attribute :created_at, :datetime, default: -> { DateTime.current }
  attribute :updated_at, :datetime, default: -> { DateTime.current }
  attribute :submission_version, :integer

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
    'Event::DeleteAdjustments',
  ].freeze

  # These are events that should not update the "Last updated at" timestamp.
  # Previously we would not even send them to the app store on creation. Now we
  # do, but with a `does_not_constitute_update` flag so that the app store
  # does not use them to update the timestamp
  LOCAL_EVENTS = [
    'Event::DraftDecision',
    'Event::Edit',
    'Event::Note',
    'Event::UndoEdit',
    'PriorAuthority::Event::DraftSendBack',
  ].freeze

  # These are events that are only created during a page load that also
  # triggers a full app store update or metadata update,
  # meaning that we don't send a separate HTTP request
  # to tell the app store about these events as soon as they are created.
  ACCOMPANIES_UPDATE_EVENTS = [
    'Event::ChangeRisk',
    'Nsm::Event::SendBack',
    'PriorAuthority::Event::SendBack',
    'Event::AutoDecision',
    'Event::Decision',
    'Event::Expiry',
  ].freeze

  # Make these methods private to ensure they are created via the various `build` methods`
  class << self
    def rehydrate(params, application_type)
      event_type = params.delete('event_type')
      klass = if event_type.in?(NAMESPACED_EVENT_TYPES)
                top_level = Submission::APPLICATION_TYPES.invert[application_type]
                "#{top_level.to_s.classify}::Event::#{event_type.camelize}".constantize
              else
                "Event::#{event_type.camelize}".constantize
              end
      klass.new(params.except('does_not_constitute_update', 'public'))
    end

    def build(**kwargs)
      construct(**kwargs).tap do |new_event|
        new_event.created_at = DateTime.current
        kwargs[:submission].events << new_event
        notify(new_event, kwargs[:submission]) unless new_event.event_type.in?(ACCOMPANIES_UPDATE_EVENTS)
      end
    end

    def notify(event, submission)
      NotifyEventAppStore.perform_now(event:, submission:)
    end
  end

  def submission=(submission)
    submission.events << self
  end

  def history?
    event_type.in?(HISTORY_EVENTS)
  end

  def title
    t('title', **title_options)
  end

  def body
    details.with_indifferent_access['comment']
  end

  def primary_user
    @primary_user ||= User.load(primary_user_id)
  end

  def as_json(*)
    super['attributes']
      .merge(
        public: PUBLIC_EVENTS.include?(event_type),
        event_type: event_type.demodulize.underscore,
        does_not_constitute_update: LOCAL_EVENTS.include?(event_type),
      )
  end

  def event_type
    self.class.to_s
  end

  private

  def title_options
    {}
  end

  def t(key, **)
    I18n.t("#{self.class.to_s.underscore}.#{key}", **)
  end
end
