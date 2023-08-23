class CreateReviewLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :review_logs, id: :uuid do |t|
      t.references :claim, null: true, type: :uuid
      t.uuid :object_id
      t.string :object_type
      t.boolean :approved

      t.timestamps
    end
  end
end
