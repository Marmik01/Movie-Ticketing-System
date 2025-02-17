class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :show, null: false, foreign_key: true
      t.string :confirmation_number
      t.string :status

      t.timestamps
    end
  end
end
