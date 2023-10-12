class UpdateUser < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'citext'

    rename_column :users, :name, :first_name

    remove_column :users, :email, :string
    add_column :users, :email, :citext

    add_column :users, :last_name, :string
    add_column :users, :auth_oid, :string
    add_column :users, :auth_subject_id, :string
    add_column :users, :last_auth_at, :datetime
    add_column :users, :first_auth_at, :datetime
    add_column :users, :deactivated_at, :datetime
    add_column :users, :invitation_expires_at, :datetime

    add_index :users, :auth_subject_id
    add_index :users, :email
  end
end
