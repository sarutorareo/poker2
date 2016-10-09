class AddDecksToHand < ActiveRecord::Migration[5.0]
  def change
    add_column :hands, :deck_str, :string
    add_column :hands, :board_str, :string
    add_column :hands, :burned_str, :string
  end
end
