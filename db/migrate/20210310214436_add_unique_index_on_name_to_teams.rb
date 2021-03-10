class AddUniqueIndexOnNameToTeams < ActiveRecord::Migration[6.1]
  def change
    add_index :teams, :name, unique: true
  end
end
