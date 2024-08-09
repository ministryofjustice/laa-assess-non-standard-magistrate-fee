class BackfillAssessmentComments < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    Submission.where(state: %w[granted rejected part_grant]).find_each do |submission|
      event = submission.events.find_by(event_type: 'Event::Decision')
      next unless event

      submission.data['assessment_comment'] = event.body
      submission.save!(touch: false)
    end

    Submission.where(state: 'sent_back', application_type: 'crm7').find_each do |submission|
      event = submission.events.find_by(event_type: 'Nsm::Event::SendBack')
      next unless event

      submission.data['assessment_comment'] = event.body
      submission.save!(touch: false)
    end
  end
end
