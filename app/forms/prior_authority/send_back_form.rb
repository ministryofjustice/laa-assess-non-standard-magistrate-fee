module PriorAuthority
  class SendBackForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :submission
    attribute :current_user
    attribute :updates_needed, array: true
    attribute :further_information_explanation
    attribute :incorrect_information_explanation

    UPDATE_TYPES = [
      FURTHER_INFORMATION = 'further_information'.freeze,
      INCORRECT_INFORMATION = 'incorrect_information'.freeze
    ].freeze

    validate :updates_needed_chosen
    validate :not_yet_assessed
    validates :further_information_explanation, presence: true, if: -> { updates_needed.include?(FURTHER_INFORMATION) }
    validates :incorrect_information_explanation, presence: true, if: lambda {
                                                                        updates_needed.include?(INCORRECT_INFORMATION)
                                                                      }

    def summary
      @summary ||= BaseViewModel.build(:application_summary, submission)
    end

    def save
      return false unless valid?

      PriorAuthorityApplication.transaction do
        stash(add_draft_send_back_event: false)
        update_local_records
        NotifyAppStore.perform_later(submission:)
      end

      true
    end

    def stash(add_draft_send_back_event: true)
      updates_needed.compact_blank! # The checkbox array introduces an empty string value

      submission.data.merge!(attributes.except('submission', 'current_user'))
      submission.save!

      return unless add_draft_send_back_event

      PriorAuthority::Event::DraftSendBack.build(submission:,
                                                 updates_needed:,
                                                 comments:,
                                                 current_user:)
    end

    def update_local_records
      submission.data['resubmission_deadline'] = resubmission_deadline

      # ordering is important here so we can order by date later and have Further info first
      append_incorrect_information_object if updates_needed.include?(INCORRECT_INFORMATION)
      append_further_information_object if updates_needed.include?(FURTHER_INFORMATION)

      submission.update!(state: PriorAuthorityApplication::SENT_BACK)
      submission.assignments.destroy_all
      save_event
    end

    def resubmission_deadline
      Rails.application.config.x.rfi.resubmission_window.from_now
    end

    def append_further_information_object
      submission.data['further_information'] ||= []

      submission.data['further_information'] << {
        caseworker_id: current_user.id,
        information_requested: further_information_explanation,
        requested_at: DateTime.current
      }
    end

    def append_incorrect_information_object
      submission.data['incorrect_information'] ||= []

      submission.data['incorrect_information'] << {
        caseworker_id: current_user.id,
        information_requested: incorrect_information_explanation,
        requested_at: DateTime.current
      }
    end

    def save_event
      PriorAuthority::Event::SendBack.build(submission:,
                                            updates_needed:,
                                            comments:,
                                            current_user:)
    end

    def comments
      ret = {}
      ret[:further_information] = further_information_explanation if updates_needed.include?(FURTHER_INFORMATION)
      ret[:incorrect_information] = incorrect_information_explanation if updates_needed.include?(INCORRECT_INFORMATION)

      ret
    end

    def updates_needed_chosen
      return if updates_needed.intersect?(UPDATE_TYPES)

      errors.add(:updates_needed, :blank)
    end

    def not_yet_assessed
      return if submission.state.in?(PriorAuthorityApplication::ASSESSABLE_STATES)

      errors.add(:base, :already_assessed)
    end
  end
end
