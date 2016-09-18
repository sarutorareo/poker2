class CreateHandUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :hand_users do |t|
      t.references :hand, null: false
      t.references :user, null: false

      t.timestamps
    end
    add_foreign_key :hand_users, :hands, column: "hand_id"
    add_foreign_key :hand_users, :users, column: "user_id"
  end
end
