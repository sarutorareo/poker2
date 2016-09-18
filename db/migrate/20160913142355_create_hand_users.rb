class CreateHandUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :hand_users do |t|
      t.references :hand, null: false
      t.references :user, null: false

      t.timestamps
    end
  end
end
