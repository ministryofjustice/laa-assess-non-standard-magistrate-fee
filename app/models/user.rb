class User < ApplicationRecord
  devise :omniauthable, :timeoutable

  scope :active, lambda {
    where('auth_subject_id IS NOT NULL AND deactivated_at IS NULL')
  }

  # include AuthUpdateable
  # include Reauthable
end
