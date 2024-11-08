module Nsm
  class SendBackForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    SENT_BACK = 'sent_back'.freeze

    attribute :send_back_comment
    attribute :current_user
    attribute :claim

    validates :claim, presence: true
    validates :send_back_comment, presence: true

    def stash
      claim.data['send_back_comment'] = send_back_comment
      claim.save!
    end

    def save
      return false unless valid?

      claim.with_lock do
        update_local_data
        AppStoreClient.new.unassign(claim)
        NotifyAppStore.perform_now(submission: claim)
      end

      true
    end

    def update_local_data
      previous_state = claim.state
      claim.data.merge!('status' => SENT_BACK,
                        'updated_at' => Time.current,
                        'assessment_comment' => send_back_comment,
                        'send_back_comment' => nil)
      add_further_information_data if FeatureFlags.nsm_rfi_loop.enabled?
      claim.sent_back!
      claim.assignments.destroy_all
      Nsm::Event::SendBack.build(submission: claim,
                                 comment: send_back_comment,
                                 previous_state: previous_state,
                                 current_user: current_user)
    end

    def add_further_information_data
      claim.data['resubmission_deadline'] = WorkingDayService.call(working_days_allowed)
      claim.data['further_information'] ||= []
      claim.data['further_information'] << {
        documents: [],
        caseworker_id: current_user.id,
        information_requested: send_back_comment,
        requested_at: DateTime.current
      }
    end

    def working_days_allowed
      Rails.application.config.x.rfi.working_day_window
    end
  end
end
