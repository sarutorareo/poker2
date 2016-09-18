class AddOrderColumnToHandUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :hand_users do |t|
      t.integer :tern_order, null: false, default: 0
    end
  end
end
