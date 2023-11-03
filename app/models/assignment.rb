class Assignment < ApplicationRecord
  belongs_to :claim
  belongs_to :user

  validates :claim, uniqueness: { conditions: -> { where(end_at: nil) } }
end
