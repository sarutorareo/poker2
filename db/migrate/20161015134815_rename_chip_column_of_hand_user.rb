class RenameChipColumnOfHandUser < ActiveRecord::Migration[5.0]
  def change
    rename_column :hand_users, :chip, :hand_total_chip
  end
end
