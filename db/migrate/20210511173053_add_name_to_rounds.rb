class AddNameToRounds < ActiveRecord::Migration[6.1]
  def change
    add_column :rounds, :name, :string
  end
end
