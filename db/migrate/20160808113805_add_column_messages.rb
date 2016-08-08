class AddColumnMessages < ActiveRecord::Migration[5.0]
  def change
    change_table :messages do |t|
      t.references :room, :default => 1
    end
  end
end
