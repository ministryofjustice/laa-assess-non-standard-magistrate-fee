class User < ApplicationRecord
  devise :omniauthable, :timeoutable

  # include AuthUpdateable
  # include Reauthable
end
