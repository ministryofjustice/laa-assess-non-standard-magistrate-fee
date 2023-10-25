class FlexibleLinkedId < ActiveRecord::Migration[7.1]
  def change
    change_column :events, :linked_id, :string
    add_index :events, [:linked_type, :linked_id]
  end
end
