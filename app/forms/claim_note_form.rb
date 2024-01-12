class ClaimNoteForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :id
  attribute :note
  attribute :current_user

  validates :claim, presence: true
  validates :note, presence: true

  def save
    return false unless valid?

    Event::Note.build(crime_application: claim, note: note, current_user: current_user)
    true
  rescue StandardError
    false
  end

  def claim
    Claim.find_by(id:)
  end
end
