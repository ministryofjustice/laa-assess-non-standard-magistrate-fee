class User < ApplicationRecord
  DummyUser = Struct.new(:display_name)

  has_many :access_logs, dependent: :destroy
  has_many :roles, dependent: :destroy

  devise :omniauthable, :timeoutable

  include AuthUpdateable
  include Reauthable

  scope :active, -> { where(deactivated_at: nil).where.not(auth_subject_id: nil) }
  scope :pending_activation, -> { where(auth_subject_id: nil, deactivated_at: nil) }

  def display_name
    "#{first_name} #{last_name}"
  end

  def supervisor?
    roles.supervisor.any?
  end

  def viewer?
    roles.viewer.any?
  end

  def pending_activation?
    auth_subject_id.nil? && first_auth_at.nil?
  end

  def self.load(user_id)
    return unless user_id

    find_by(id: user_id) || DummyUser.new(I18n.t('helpers.non_local_caseworker'))
  end
end
