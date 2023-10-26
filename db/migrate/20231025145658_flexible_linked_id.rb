class FlexibleLinkedId < ActiveRecord::Migration[7.1]
  def up
    change_column :events, :linked_id, :string
    add_index :events, [:linked_type, :linked_id]
  end

  def down
    change_column :events, :linked_id, "uuid USING linked_id::uuid"
    remove_index :events, [:linked_type, :linked_id]
  end
end
