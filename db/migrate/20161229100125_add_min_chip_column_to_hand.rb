class AddMinChipColumnToHand < ActiveRecord::Migration[5.0]
  def change
    add_column :hands, :call_chip, :integer, :null => false, :default => 0
    add_column :hands, :min_raise_chip, :integer, :null => false, :default => 0
  end
end
