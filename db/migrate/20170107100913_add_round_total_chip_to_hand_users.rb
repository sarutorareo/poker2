class AddRoundTotalChipToHandUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :hand_users, :round_total_chip, :integer, :null => false, :default => 0
  end
end
