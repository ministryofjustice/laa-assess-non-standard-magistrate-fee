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
    'Event::DeleteAdjustments',
  ].freeze

  # These are events that we know can exist in our local database for a significant
  # period without existing in the app store database. All other events are either
  # synced to the app store immediately after creation via a `.notify` call, or
  # only created as part of a larger action that is followed immediately by a
  # call to `NotifyAppStore` which syncs all events anyway.
  # It is important to keep track of these so that we can infer what the app
  # store thinks the latest event date is (so that the 'last updated' date
  # we display in the UI is consistent with the value the app store uses
  # for sorting and filtering search results)
  LOCAL_EVENTS = [
    'Event::DraftDecision',
    'Event::Edit',
    'Event::Note',
    'Event::UndoEdit',
    'PriorAuthority::Event::DraftSendBack',
  ].freeze

  scope :history, -> { where(event_type: HISTORY_EVENTS).order(created_at: :desc) }

  scope :non_local, -> { where.not(event_type: LOCAL_EVENTS) }

  # simplifies the rehydrate process
  attribute :public

  # Make these methods private to ensure they are created via the various `build` methods`
  class << self
    protected :new
    private :create

    def rehydrate!(params, application_type)
      return if find_by(id: params['id'])

      create_dummy_users_if_non_production(params) unless HostEnv.production?

      event_type = params.delete('event_type')
      klass = if event_type.in?(NAMESPACED_EVENT_TYPES)
                top_level = Submission::APPLICATION_TYPES.invert[application_type]
                "#{top_level.to_s.classify}::Event::#{event_type.classify}".constantize
              else
                "Event::#{event_type.classify}".constantize
              end
      klass.new(params).save!
    end

    private

    def create_dummy_users_if_non_production(params)
      create_dummy_user_if_non_production(params['primary_user_id'])
      create_dummy_user_if_non_production(params['secondary_user_id'])
    end

    def create_dummy_user_if_non_production(user_id)
      return if user_id.blank?

      # This rather block-heavy chunk of code is cribbed from
      # https://github.com/rails/rails/issues/43634#issuecomment-987240280
      ActiveRecord::Base.transaction do
        ActiveRecord::Base.with_advisory_lock("create_dummy_user-#{user_id}", transaction: true) do
          ActiveRecord::Base.uncached do
            User.find_or_initialize_by(id: user_id) do |user|
              user.update!(dummy_attributes(user_id))
              user.roles.create! role_type: Role::VIEWER
            end
          end
        end
      end
    end

    def dummy_attributes(user_id)
      {
        first_name: user_id.split('-').first,
        email: "#{user_id}@fake.com",
        last_name: 'branchbuilder',
        auth_oid: user_id,
        auth_subject_id: user_id,
        last_auth_at: Time.zone.now,
        first_auth_at: Time.zone.now
      }
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
      .except('submission_id', 'notify_app_store_completed')
      .merge(
        public: PUBLIC_EVENTS.include?(event_type),
        event_type: event_type.demodulize.underscore
      )
  end

  def notify
    NotifyEventAppStore.perform_later(event: self)
  end

  private

  def title_options
    {}
  end

  def t(key, **)
    I18n.t("#{self.class.to_s.underscore}.#{key}", **)
  end
end
