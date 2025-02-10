class CreateScreens < ActiveRecord::Migration[8.0]
  def change
    create_table :screens do |t|
      t.string :name
      t.integer :capacity

      t.timestamps
    end
  end
end
