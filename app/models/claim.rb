class Claim < ApplicationRecord
  has_many :assignments
  has_one :current_assignment, -> { where(to_date: nil) }, class_name: 'Assignment'
  has_many :versions
  has_many :current_version, -> { where(version: current_versions) }, class_name: 'Version'
end
