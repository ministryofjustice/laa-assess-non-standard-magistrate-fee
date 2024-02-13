module Nsm
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

      AppStoreService.create_note(claim, note: note, user_id: current_user.id)
      true
    end

    def claim
      @claim ||= AppStoreService.get(id)
    end
  end
end
