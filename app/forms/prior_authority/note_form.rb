module PriorAuthority
  class NoteForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :note
    attribute :submission
    attribute :current_user

    validates :note, presence: true

    def save
      return false unless valid?

      ::Event::Note.build(submission:, note:, current_user:)
      true
    end

    def summary
      @summary ||= BaseViewModel.build(:application_summary, submission)
    end
  end
end
