class AddBettingRoundColumnToHand < ActiveRecord::Migration[5.0]
  def change
    add_column :hands, :betting_round, :integer, :null => false, :default => 0
  end
end
