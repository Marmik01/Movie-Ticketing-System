class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :email
      t.string :password
      t.string :phone
      t.text :address
      t.string :credit_card_info
      t.boolean :is_admin

      t.timestamps
    end
  end
end
