class Assignment < ApplicationRecord
  belongs_to :submission
  belongs_to :user

  validates :submission, uniqueness: true

  delegate :display_name, to: :user
end
