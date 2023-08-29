class Claim < ApplicationRecord
  has_many :assignments
  has_one :current_assignment, -> { where(to_date: nil) }, class_name: 'Assignment'
  has_many :versions
  has_one :current_version_record, -> (claim) { where(version: claim.current_version) }, class_name: 'Version'

  validates :risk, inclusion: { in: %w[low medium high] }
  validates :current_version, numericality: { only_integer: true, greater_than: 0 }
end
