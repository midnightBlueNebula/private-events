class CreateCreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :create_events do |t|
      t.references :user, foreign_key: true
      t.references :event, foreign_key: true

      t.timestamps
    end
  end
end
