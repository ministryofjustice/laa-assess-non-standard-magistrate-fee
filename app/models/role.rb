class Role < ApplicationRecord
  ROLE_TYPES = [
    CASEWORKER = 'caseworker'.freeze,
    SUPERVISOR = 'supervisor'.freeze,
    VIEWER = 'viewer'.freeze
  ].freeze

  belongs_to :user

  validates :role_type, inclusion: { in: ROLE_TYPES }

  scope :caseworker, -> { where(role_type: CASEWORKER) }
  scope :supervisor, -> { where(role_type: SUPERVISOR) }
  scope :viewer, -> { where(role_type: VIEWER) }
end
