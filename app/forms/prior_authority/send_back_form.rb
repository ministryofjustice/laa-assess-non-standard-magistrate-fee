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
        NotifyAppStore.process(submission:)
      end

      true
    end

    def stash(add_draft_send_back_event: true)
      updates_needed.compact_blank! # The checkbox array introduces an empty string value

      submission.data.merge!(attributes.except('submission', 'current_user'))
      submission.save!

      return unless add_draft_send_back_event

      Event::DraftSendBack.build(submission:,
                                 comment:,
                                 current_user:)
    end

    def update_local_records
      submission.data['resubmission_deadline'] = Rails.application.config.x.rfi.resubmission_window.from_now

      submission.update!(state: PriorAuthorityApplication::SENT_BACK)
      submission.assignments.destroy_all
      save_event
    end

    def save_event
      previous_state = submission.state
      Event::SendBack.build(submission:,
                            comment:,
                            previous_state:,
                            current_user:)
    end

    def comment
      if updates_needed.select(&:present?) == [FURTHER_INFORMATION]
        return further_information_explanation
      elsif updates_needed.select(&:present?) == [INCORRECT_INFORMATION]
        return incorrect_information_explanation
      end

      [further_information_explanation, incorrect_information_explanation].select(&:present?)
                                                                          .join(' ')
    end

    def updates_needed_chosen
      return if updates_needed.intersect?(UPDATE_TYPES)

      errors.add(:updates_needed, :blank)
    end

    def not_yet_assessed
      return unless submission.state.in?(PriorAuthorityApplication::ASSESSED_STATES)

      errors.add(:base, :already_assessed)
    end
  end
end
