class UpdateSubmission
  attr_reader :submission

  delegate :errors, to: :submission

  def self.call(record)
    new(record).save
  end

  def initialize(record)
    @submission = Submission.find_or_initialize_by(id: record['application_id'])
    @record = record
  end

  def save
    PriorAuthorityApplication.transaction do
      update_submission
    end

    submission
  end

  def assign_attributes
    submission.assign_attributes(Submission.attributes_from_app_store_data(@record))
    submission.received_on ||= Time.zone.today
  end

  private

  def update_submission
    assign_attributes
    submission.save!

    @record['events']&.each do |event|
      submission.events.rehydrate!(event, submission.application_type)
    end
  end
end
