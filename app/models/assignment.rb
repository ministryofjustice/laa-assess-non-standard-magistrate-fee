class Assignment < ApplicationRecord
  belongs_to :claim
  belongs_to :user

  validates :claim, uniqueness: true

  delegate :display_name, to: :user
end
