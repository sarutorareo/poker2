class AddChipAndLastActionColumnToHandUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :hand_users do |t|
      t.integer :last_action_kbn, null: true
      t.integer :chip, null: false, default: 0
    end
  end
end
