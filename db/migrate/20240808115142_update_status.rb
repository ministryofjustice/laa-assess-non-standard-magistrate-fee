class UpdateStatus < ActiveRecord::Migration[7.1]
  def change
    Claim.where(state: 'further_info').update_all(state: 'sent_back')
  end
end
