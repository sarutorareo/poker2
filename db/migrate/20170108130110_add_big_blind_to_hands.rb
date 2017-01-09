class AddBigBlindToHands < ActiveRecord::Migration[5.0]
  def change
    add_column :hands, :big_blind, :float, :null => false, :default => 100
  end
end
