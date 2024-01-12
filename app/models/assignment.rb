class Assignment < ApplicationRecord
  belongs_to :crime_application
  belongs_to :user

  validates :crime_application, uniqueness: true

  delegate :display_name, to: :user
end
