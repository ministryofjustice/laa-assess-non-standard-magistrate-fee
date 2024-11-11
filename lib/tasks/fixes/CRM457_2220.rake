namespace :CRM457_2220 do
  desc "un-expire app and notify app-store is sent_back"
  task fix: :environment do
    # We have all the data we need saved locally for this record - we
    # need to refresh the resubmission deadline, reset expiry status to sent_back
    # and delete the associated Expiry Event for consistency (this event was created in error)

    sub_id = '507c6b43-a3c5-4520-b610-b639b88c945c'
    exp_id = '4e1d61b1-52c2-4a72-bc61-e2ed0d4c5f10'

    resubmission_deadline = WorkingDayService.call(Rails.application.config.x.rfi.working_day_window)
    puts "resubmission_deadline: #{resubmission_deadline}"
    submission = PriorAuthorityApplication.find(sub_id)
    puts "submission_id: #{submission.id}"
    submission.data.merge!('updated_at' => Time.current,
                           'status' => PriorAuthorityApplication::SENT_BACK,
                           'resubmission_deadline' => resubmission_deadline)
    submission.sent_back!
    puts "submission_state: #{submission.state}"

    Event.find(exp_id).destroy
    puts "Expiry Event: #{exp_id} destroyed"

    puts "Attempt NotifyAppStore START"
    NotifyAppStore.perform_later(submission:)
    puts "Attempt NotifyAppStore END"
  end
end
